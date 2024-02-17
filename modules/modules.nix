{
  pkgs,
  lib,
  check ? true,
}: let
  inherit (lib) mkDefault;

  plugins = builtins.map (p: ./plugins + "/${p}") [
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

  core = builtins.map (p: ./core + "/${p}") [
    "build"
    "mappings"
    "warnings"
  ];

  modules = [
    ./neovim
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
in
  [pkgsModule] ++ (lib.concatLists [core modules plugins])
