{
  pkgs,
  lib,
  check ? true,
}: let
  inherit (lib.modules) mkDefault;
  inherit (lib.lists) concatLists;

  core = map (p: ./core + "/${p}") [
    "build"
    "warnings"
  ];

  neovim = map (p: ./neovim + "/${p}") [
    "basic"
    "mappings"
  ];

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

  allModules = concatLists [core neovim plugins];

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
