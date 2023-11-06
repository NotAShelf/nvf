{
  pkgs,
  lib,
  check ? true,
}: let
  modules = [
    ./completion
    ./theme
    ./core
    ./basic
    ./statusline
    ./tabline
    ./filetree
    ./visuals
    ./lsp
    ./treesitter
    ./autopairs
    ./snippets
    ./git
    ./minimap
    ./dashboard
    ./utility
    ./rich-presence
    ./notes
    ./terminal
    ./ui
    ./assistant
    ./session
    ./comments
    ./projects
    ./languages
    ./debugger
  ];

  pkgsModule = {config, ...}: {
    config = {
      _module = {
        inherit check;
        args = {
          baseModules = modules;
          pkgsPath = lib.mkDefault pkgs.path;
          pkgs = lib.mkDefault pkgs;
        };
      };
    };
  };
in
  modules ++ [pkgsModule]
