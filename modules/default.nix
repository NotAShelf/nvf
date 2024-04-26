inputs: {
  configuration,
  pkgs,
  lib ? pkgs.lib,
  check ? true,
  extraSpecialArgs ? {},
  extraModules ? [],
}: let
  inherit (builtins) map filter isString toString getAttr;
  inherit (pkgs) wrapNeovimUnstable vimPlugins;
  inherit (pkgs.vimUtils) buildVimPlugin;
  inherit (pkgs.neovimUtils) makeNeovimConfig;
  inherit (lib.strings) makeBinPath escapeShellArgs concatStringsSep;
  inherit (lib.lists) concatLists optional;
  inherit (lib.attrsets) recursiveUpdate;
  inherit (lib.asserts) assertMsg;

  # call the extedended library with `lib` and `inputs` as arguments
  # lib is used to provide the standard library functions to the extended library
  # but it can be overridden while this file is being called
  # inputs is used to pass inputs to the plugin autodiscovery function
  extendedLib = import ../lib/stdlib-extended.nix lib inputs;

  # import modules.nix with `check`, `pkgs` and `lib` as arguments
  # check can be disabled while calling this file is called
  # to avoid checking in all modules
  nvimModules = import ./modules.nix {
    inherit check pkgs;
    lib = extendedLib;
  };

  # evaluate the extended library with the modules
  # optionally with any additional modules passed by the user
  module = extendedLib.evalModules {
    specialArgs = recursiveUpdate {modulesPath = toString ./.;} extraSpecialArgs;
    modules = concatLists [[configuration] nvimModules extraModules];
  };

  # alias to the internal configuration
  vimOptions = module.config.vim;

  # build a vim plugin with the given name and arguments
  # if the plugin is nvim-treesitter, warn the user to use buildTreesitterPlug
  # instead
  buildPlug = {pname, ...} @ args:
    assert assertMsg (pname != "nvim-treesitter") "Use buildTreesitterPlug for building nvim-treesitter.";
      buildVimPlugin (args
        // {
          version = "master";
          src = getAttr ("plugin-" + pname) inputs;
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

  # built (or "normalized") plugins that are modified
  builtStartPlugins = buildConfigPlugins vimOptions.startPlugins;
  builtOptPlugins = map (package: {
    plugin = package;
    optional = false;
  }) (buildConfigPlugins vimOptions.optPlugins);

  # combine built start and optional plugins
  # into a single list
  plugins = builtStartPlugins ++ builtOptPlugins;

  # additional Lua and Python3 packages, mapped to their respective functions
  # to conform to the format makeNeovimConfig expects. end user should
  # only ever need to pass a list of packages, which are modified
  # here
  extraLuaPackages = ps: map (x: ps.${x}) vimOptions.luaPackages;
  extraPython3Packages = ps: map (x: ps.${x}) vimOptions.python3Packages;

  extraWrapperArgs = concatStringsSep " " (optional (vimOptions.extraPackages != []) ''
    --unset XDG_DATA_DIRS \
    --prefix PATH : "${makeBinPath vimOptions.extraPackages}"
  '');

  # wrap user's desired neovim package with the desired neovim configuration
  # using wrapNeovimUnstable and makeNeovimConfig from nixpkgs.
  # the makeNeovimConfig function takes the following arguments:
  #  - withPython (bool)
  #  - extraPython3Packages (lambda)
  #  - withNodeJs (bool)
  #  - withRuby (bool)
  #  - extraLuaPackages (lambda)
  #  - plugins (list)
  #  - customRC (string)
  # and returns the wrapped package
  neovimConfigured = makeNeovimConfig {
    inherit (vimOptions) viAlias vimAlias withRuby withNodeJs withPython3;
    inherit plugins extraLuaPackages extraPython3Packages;
    customRC = vimOptions.builtConfigRC;
  };

  neovim-wrapped = wrapNeovimUnstable vimOptions.package (recursiveUpdate neovimConfigured {
    wrapperArgs = escapeShellArgs neovimConfigured.wrapperArgs + " " + extraWrapperArgs;
  });
in {
  inherit (module) options config;
  inherit (module._module.args) pkgs;

  # expose wrapped neovim package
  neovim = neovim-wrapped.overrideAttrs (old: {
    generatedWrapperArgs = (old.generatedWrapperArgs or []) ++ ["--set" "NVIM_APPNAME" "nvf"];
  });
}
