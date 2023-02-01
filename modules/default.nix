{inputs}: {
  configuration,
  pkgs,
  lib ? pkgs.lib,
  check ? true,
  extraSpecialArgs ? {},
}: let
  inherit (pkgs) neovim-unwrapped wrapNeovim vimPlugins;
  inherit (builtins) map filter isString toString getAttr hasAttr attrNames;
  inherit (pkgs.vimUtils) buildVimPluginFrom2Nix;

  extendedLib = import ./lib/stdlib-extended.nix lib;

  nvimModules = import ./modules.nix {
    inherit check pkgs;
    lib = extendedLib;
  };

  module = extendedLib.evalModules {
    modules = [configuration] ++ nvimModules;
    specialArgs =
      {
        modulesPath = toString ./.;
      }
      // extraSpecialArgs;
  };

  buildPlug = name:
    buildVimPluginFrom2Nix rec {
      pname = name;
      version = "master";
      src = assert lib.asserts.assertMsg (name != "nvim-treesitter") "Use buildTreesitterPlug for building nvim-treesitter.";
        getAttr pname inputs;
    };

  buildTreesitterPlug = grammars: vimPlugins.nvim-treesitter.withPlugins (_: grammars);

  vimOptions = module.config.vim;

  buildConfigPlugins = plugins:
    map
    (plug: (
      if (isString plug)
      then
        (
          if (plug == "nvim-treesitter")
          then (buildTreesitterPlug vimOptions.treesitter.grammars)
          else (buildPlug plug)
        )
      else plug
    ))
    (filter
      (f: f != null)
      plugins);

  neovim = wrapNeovim neovim-unwrapped {
    viAlias = vimOptions.viAlias;
    vimAlias = vimOptions.vimAlias;
    configure = {
      customRC = vimOptions.builtConfigRC;

      packages.myVimPackage = {
        start = buildConfigPlugins vimOptions.startPlugins;
        opt = buildConfigPlugins vimOptions.optPlugins;
      };
    };
  };
in {
  inherit (module) options config;
  inherit (module._module.args) pkgs;
  inherit neovim;
}
