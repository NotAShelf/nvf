{
  self,
  inputs,
  lib,
}: {
  pkgs,
  extraSpecialArgs ? {},
  modules ? [],
}: let
  inherit (builtins) toString;
  inherit (lib.lists) concatLists;

  # import modules.nix with `check`, `pkgs` and `lib` as arguments
  # check can be disabled while calling this file is called
  # to avoid checking in all modules
  nvimModules = import ./modules.nix {inherit pkgs lib;};

  # evaluate the extended library with the modules
  # optionally with any additional modules passed by the user
  module = lib.evalModules {
    specialArgs =
      extraSpecialArgs
      // {
        inherit self inputs;
        modulesPath = toString ./.;
      };
    modules = concatLists [
      nvimModules
      modules
    ];
  };
in {
  inherit (module) options config;
  inherit (module._module.args) pkgs;

  # Expose wrapped neovim-package for userspace
  # or module consumption.
  neovim = module.config.vim.build.finalPackage;
}
