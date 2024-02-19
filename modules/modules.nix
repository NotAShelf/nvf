{
  pkgs,
  lib,
  check ? true,
}: let
  inherit (builtins) map;
  inherit (lib.modules) mkDefault;
  inherit (lib.lists) concatLists;

  # map each plugin from our plugins module into a list
  plugins = map (p: ./plugins + "/${p}") [
    "completion"
    "theme"
    "statusline"
    "tabline"
    "filetree"
    "visuals"
    "lsp"
    "treesitter"
    "autopairs"
    "snippets"
    "git"
    "minimap"
    "dashboard"
    "utility"
    "rich-presence"
    "notes"
    "terminal"
    "ui"
    "assistant"
    "session"
    "comments"
    "projects"
    "languages"
    "debugger"
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
