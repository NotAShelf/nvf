{
  self,
  inputs,
  ...
}: {
  pkgs,
  extraSpecialArgs ? {},
  modules ? [],
  # deprecated
  extraModules ? [],
  configuration ? {},
}: let
  inherit (pkgs) lib;
  inherit (lib.modules) evalModules;
  inherit (lib.strings) toString;
  inherit (lib.trivial) warn;
  inherit (lib.lists) concatLists optional optionals;

  # import modules.nix with `check` and `pkgs` as arguments
  # check can be disabled while calling this file is called
  # to avoid checking in all modules
  nvimModules = import ./modules.nix {inherit pkgs;};

  # evaluate the extended library with the modules
  # optionally with any additional modules passed by the user
  module = evalModules {
    specialArgs =
      extraSpecialArgs
      // {
        inherit self inputs;
        modulesPath = toString ./.;
      };
    modules = concatLists [
      nvimModules
      modules
      (optional (configuration != {}) (warn ''
          nvf: passing 'configuration' to lib.neovimConfiguration is deprecated.
        ''
        configuration))

      (optionals (extraModules != []) (warn ''
          nvf: passing 'extraModules' to lib.neovimConfiguration is deprecated, use 'modules' instead.
        ''
        extraModules))
    ];
  };
in {
  inherit (module) options config;
  inherit (module._module.args) pkgs;

  # Expose wrapped neovim-package for userspace
  # or module consumption.
  neovim = module.config.vim.build.finalPackage;
}
