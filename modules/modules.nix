{
  pkgs,
  lib,
  check ? true,
}: let
  inherit (lib.modules) mkDefault;
  inherit (lib.lists) concatLists;

  # The core neovim modules.
  # Contains configuration for core neovim features
  # such as spellchecking, mappings, and the init script (init.vim).
  neovim = map (p: ./neovim + "/${p}") [
    "init"
    "mappings"
  ];

  # Individual plugin modules, separated by the type of plugin.
  # While adding a new type, you must make sure your type is
  # included in the list below.
  plugins = map (p: ./plugins + "/${p}") [
    "assistant"
    "autopairs"
    "comments"
    "completion"
    "dashboard"
    "debugger"
    "filetree"
    "git"
    "languages"
    "lsp"
    "minimap"
    "notes"
    "projects"
    "rich-presence"
    "session"
    "snippets"
    "spellcheck"
    "statusline"
    "tabline"
    "terminal"
    "theme"
    "treesitter"
    "ui"
    "utility"
    "visuals"
  ];

  # The neovim wrapper, used to build a wrapped neovim package
  # using the configuration passed in `neovim` and `plugins` modules.
  wrapper = map (p: ./wrapper + "/${p}") [
    "build"
    "warnings"
  ];

  allModules = concatLists [neovim plugins wrapper];

  pkgsModule = {config, ...}: {
    config = {
      _module = {
        inherit check;
        args = {
          baseModules = allModules;
          pkgsPath = mkDefault pkgs.path;
          pkgs = mkDefault pkgs;
        };
      };
    };
  };
in
  allModules ++ [pkgsModule]
