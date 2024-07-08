inputs: {
  configuration,
  pkgs,
  lib,
  check ? true,
  extraSpecialArgs ? {},
  extraModules ? [],
}: let
  inherit (pkgs) vimPlugins;
  inherit (pkgs.vimUtils) buildVimPlugin;
  inherit (lib.strings) makeBinPath isString toString;
  inherit (lib.lists) filter map concatLists;
  inherit (lib.attrsets) recursiveUpdate getAttr;
  inherit (lib.asserts) assertMsg;

  # import modules.nix with `check`, `pkgs` and `lib` as arguments
  # check can be disabled while calling this file is called
  # to avoid checking in all modules
  nvimModules = import ./modules.nix {
    inherit pkgs check lib;
  };

  # evaluate the extended library with the modules
  # optionally with any additional modules passed by the user
  module = lib.evalModules {
    specialArgs = recursiveUpdate {modulesPath = toString ./.;} extraSpecialArgs;
    modules = concatLists [[configuration] nvimModules extraModules];
  };

  # alias to the internal configuration
  vimOptions = module.config.vim;

  # build a vim plugin with the given name and arguments
  # if the plugin is nvim-treesitter, warn the user to use buildTreesitterPlug
  # instead
  buildPlug = {pname, ...} @ attrs: let
    src = getAttr ("plugin-" + pname) inputs;
  in
    pkgs.runCommand "${pname}-${src.shortRev or src.shortDirtyRev or "dirty"}" attrs
    ''
      mkdir -p $out
      cp -r ${src}/. $out
    '';

  noBuildPlug = {pname, ...} @ attrs: let
    input = getAttr ("plugin-" + pname) inputs;
  in
    {
      version = input.shortRev or input.shortDirtyRev or "dirty";
      outPath = getAttr ("plugin-" + pname) inputs;
    }
    // attrs;

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
            (
              buildPlug
              {
                pname = "flutter-tools";
                patches = [../patches/flutter-tools.patch];
              }
            )
          else noBuildPlug {pname = plug;}
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
    optional = true;
  }) (buildConfigPlugins vimOptions.optPlugins);

  # additional Lua and Python3 packages, mapped to their respective functions
  # to conform to the format makeNeovimConfig expects. end user should
  # only ever need to pass a list of packages, which are modified
  # here
  extraLuaPackages = ps: map (x: ps.${x}) vimOptions.luaPackages;
  extraPython3Packages = ps: map (x: ps.${x}) vimOptions.python3Packages;

  # Wrap the user's desired (unwrapped) Neovim package with arguments that'll be used to
  # generate a wrapped Neovim package.
  neovim-wrapped = inputs.mnw.lib.wrap pkgs {
    neovim = vimOptions.package;
    plugins = concatLists [builtStartPlugins builtOptPlugins];
    appName = "nvf";
    initViml = vimOptions.builtConfigRC;
    extraBinPath = vimOptions.extraPackages;

    inherit (vimOptions) viAlias vimAlias withRuby withNodeJs withPython3;
    inherit extraLuaPackages extraPython3Packages;
  };
in {
  inherit (module) options config;
  inherit (module._module.args) pkgs;

  # expose wrapped neovim-package
  neovim = neovim-wrapped;
}
