{
  inputs,
  lib,
}: let
  modulesWithInputs = import ../modules inputs;
in
  {
    modules ? [],
    pkgs,
    check ? true,
    extraSpecialArgs ? {},
    extraModules ? [],
    ...
  }:
    modulesWithInputs {
      inherit pkgs lib check extraSpecialArgs extraModules;
      configuration.imports = modules;
    }
