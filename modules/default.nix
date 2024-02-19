inputs: {
  configuration,
  pkgs,
  lib ? pkgs.lib,
  check ? true,
  extraSpecialArgs ? {},
}: let
  inherit (builtins) map filter isString toString getAttr;
  inherit (lib.asserts) assertMsg;

  # extend nixpkgs.lib with our own set of functions
  extendedLib = import ../lib/stdlib-extended.nix lib;

  # define neovim modules that will be used to configure neovim
  nvimModules = import ./modules.nix {
    inherit check pkgs;
    lib = extendedLib;
  };

  module = extendedLib.evalModules {
    modules = [configuration] ++ nvimModules;
    specialArgs = {modulesPath = toString ./.;} // extraSpecialArgs;
  };

  vimOptions = module.config.vim;

  inherit (pkgs) wrapNeovim vimPlugins;
  inherit (pkgs.vimUtils) buildVimPlugin;

  extraLuaPackages = ps: map (x: ps.${x}) vimOptions.luaPackages;

  buildPlug = {pname, ...} @ args:
    assert assertMsg (pname != "nvim-treesitter") "Use buildTreesitterPlug for building nvim-treesitter.";
      buildVimPlugin (args
        // {
          version = "master";
          src = getAttr pname inputs;
        });

  buildTreesitterPlug = grammars: vimPlugins.nvim-treesitter.withPlugins (_: grammars);

  buildConfigPlugins = plugins:
    map
    (plug: (
      if (isString plug)
      then
        (
          if (plug == "nvim-treesitter")
          then (buildTreesitterPlug vimOptions.treesitter.grammars)
          else if (plug == "flutter-tools-patched")
          then
            (buildPlug {
              pname = "flutter-tools";
              patches = [../patches/flutter-tools.patch];
            })
          else (buildPlug {pname = plug;})
        )
      else plug
    ))
    (filter
      (f: f != null)
      plugins);

  # configure the neovim wrapper
  # for details on how to use the wrapper, see:
  # - https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/neovim/wrapper.nix
  # - https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/neovim/utils.nix
  neovim = wrapNeovim vimOptions.package {
    inherit (vimOptions) viAlias;
    inherit (vimOptions) vimAlias;

    inherit extraLuaPackages;

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
