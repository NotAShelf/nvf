inputs: {
  configuration,
  pkgs,
  lib,
  check ? true,
  extraSpecialArgs ? {},
  extraModules ? [],
}: let
  inherit (pkgs) vimPlugins;
  inherit (lib.strings) isString toString;
  inherit (lib.lists) filter map concatLists;
  inherit (lib.attrsets) recursiveUpdate;
  inherit (builtins) baseNameOf;

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
  buildPlug = attrs: let
    src = inputs."plugin-${attrs.pname}";
  in
    pkgs.stdenvNoCC.mkDerivation ({
        version = src.shortRev or src.shortDirtyRev or "dirty";

        inherit src;

        buildPhase = lib.optionalString vimOptions.byteCompileLua ''
          runHook preBuild
          find . -type f -name '*.lua' -exec luajit -bd -- {} {} \;
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out
          cp -r . $out

          runHook postInstall
        '';
      }
      // attrs);

  buildTreesitterPlug = grammars: vimPlugins.nvim-treesitter.withPlugins (_: grammars);

  pluginBuilders = {
    nvim-treesitter = buildTreesitterPlug vimOptions.treesitter.grammars;
    flutter-tools-patched =
      buildPlug
      {
        pname = "flutter-tools";
        patches = [../patches/flutter-tools.patch];
      };
  };

  buildConfigPlugins = plugins:
    map
    (
      plug:
        if (isString plug)
        then pluginBuilders.${plug} or (buildPlug {pname = plug;})
        else plug
    )
    (filter (f: f != null) plugins);

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

  luaConfig =
    if vimOptions.byteCompileLua
    then pkgs.runCommandLocal "init.lua" {text = vimOptions.builtLuaConfigRC;} "${pkgs.luajit}/bin/luajit -bd -- - $out <<< \"$text\""
    else pkgs.writeText "init.lua" vimOptions.builtLuaConfigRC;

  extraLuaFiles =
    if vimOptions.byteCompileLua
    then map (file: pkgs.runCommandLocal (baseNameOf file) {} "${pkgs.luajit}/bin/luajit -bd -- ${file} $out") vimOptions.extraLuaFiles
    else vimOptions.extraLuaFiles;

  # Wrap the user's desired (unwrapped) Neovim package with arguments that'll be used to
  # generate a wrapped Neovim package.
  neovim-wrapped = inputs.mnw.lib.wrap pkgs {
    neovim = vimOptions.package;
    plugins = concatLists [builtStartPlugins builtOptPlugins];
    appName = "nvf";
    extraBinPath = vimOptions.extraPackages;
    luaFiles = [luaConfig] ++ extraLuaFiles;

    inherit (vimOptions) viAlias vimAlias withRuby withNodeJs withPython3;
    inherit extraLuaPackages extraPython3Packages;
  };

  # Additional helper scripts for printing and displaying nvf configuration
  # in your commandline.
  printConfig = pkgs.writers.writeDashBin "nvf-print-config" ''
    cat << EOF
      ${vimOptions.builtLuaConfigRC}
    EOF
  '';

  printConfigPath = pkgs.writers.writeDashBin "nvf-print-config-path" ''
    realpath ${pkgs.writeTextFile {
      name = "nvf-init.lua";
      text = vimOptions.builtLuaConfigRC;
    }}
  '';
in {
  inherit (module) options config;
  inherit (module._module.args) pkgs;

  # Expose wrapped neovim-package for userspace
  # or module consumption.
  neovim = pkgs.symlinkJoin {
    name = "nvf-with-helpers";
    paths = [neovim-wrapped printConfig printConfigPath];
    postBuild = "echo helpers added";

    meta = {
      description = "Wrapped version of Neovim with additional helper scripts";
      mainProgram = "nvim";
    };
  };
}
