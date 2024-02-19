{
  pkgs,
  lib,
  check ? true,
}: let
  inherit (builtins) map;
  inherit (lib.modules) mkDefault;
  inherit (lib.lists) concatLists;

  # map each plugin from our plugins module into a list
  # while adding a new parent module, it needs to be added
  # here by name before it can be evaluated
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
    "statusline"
    "tabline"
    "terminal"
    "theme"
    "treesitter"
    "ui"
    "utility"
    "visuals"
  ];

  core = map (p: ./core + "/${p}") [
    "build"
    "mappings"
    "warnings"
  ];

  neovim = map (p: ./neovim + "/${p}") [
    "basic"
    "maps"
    "spellcheck"
  ];

  pkgsModule = {config, ...}: {
    config = {
      _module = {
        inherit check;
        args = {
          baseModules = modules;
          pkgsPath = mkDefault pkgs.path;
          pkgs = mkDefault pkgs;
        };
      };
    };
  };

  modules = concatLists [core neovim plugins] ++ [pkgsModule];
in
  modules
