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
    ./tidal
    ./autopairs
    ./snippets
    ./binds
    ./markdown
    ./telescope
    ./git
    ./minimap
    ./dashboard
    ./notifications
    ./utility
    ./presence
    ./notes
  ];

  pkgsModule = {config, ...}: {
    config = {
      _module.args.baseModules = modules;
      _module.args.pkgsPath = lib.mkDefault pkgs.path;
      _module.args.pkgs = lib.mkDefault pkgs;
      _module.check = check;
    };
  };
in
  modules ++ [pkgsModule]
