{
  pkgs,
  lib,
  check ? true,
}: let
  modules = [
    ./basic
    ./core
    ./languages
    ./plugins
    ./themes
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
