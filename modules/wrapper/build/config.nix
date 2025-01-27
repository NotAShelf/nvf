{
  inputs,
  lib,
  config,
  pkgs,
  ...
}
: let
  inherit (pkgs) vimPlugins;
  inherit (lib.strings) isString;
  inherit (lib.lists) filter map;
  inherit (builtins) path;

  # alias to the internal configuration
  vimOptions = config.vim;

  noBuildPlug = pname: let
    input = inputs."plugin-${pname}";
    version = input.shortRev or input.shortDirtyRev or "dirty";
  in {
    # vim.lazy.plugins relies on pname, so we only set that here
    # version isn't needed for anything, but inherit it anyway for correctness
    inherit pname version;
    outPath = path {
      name = "${pname}-0-unstable-${version}";
      path = input.outPath;
    };
    passthru.vimPlugin = false;
  };

  # build a vim plugin with the given name and arguments
  # if the plugin is nvim-treesitter, warn the user to use buildTreesitterPlug
  # instead
  buildPlug = attrs: let
    input = inputs."plugin-${attrs.pname}";
  in
    pkgs.vimUtils.buildVimPlugin (
      {
        version = input.shortRev or input.shortDirtyRev or "dirty";
        src = input.outPath;
      }
      // attrs
    );

  buildTreesitterPlug = grammars: vimPlugins.nvim-treesitter.withPlugins (_: grammars);

  pluginBuilders = {
    nvim-treesitter = buildTreesitterPlug vimOptions.treesitter.grammars;
    flutter-tools-patched = buildPlug {
      pname = "flutter-tools";
      patches = [./patches/flutter-tools.patch];

      # Disable failing require check hook checks
      nvimSkipModule = [
        "flutter-tools.devices"
        "flutter-tools.dap"
        "flutter-tools.runners.job_runner"
        "flutter-tools.decorations"
        "flutter-tools.commands"
        "flutter-tools.executable"
        "flutter-tools.dev_tools"
      ];
    };
    inherit (pkgs) blink-cmp;
  };

  buildConfigPlugins = plugins:
    map (
      plug:
        if (isString plug)
        then pluginBuilders.${plug} or (noBuildPlug plug)
        else plug
    ) (filter (f: f != null) plugins);

  # built (or "normalized") plugins that are modified
  builtStartPlugins = buildConfigPlugins vimOptions.startPlugins;
  builtOptPlugins = map (package: package // {optional = true;}) (buildConfigPlugins vimOptions.optPlugins);

  # additional Lua and Python3 packages, mapped to their respective functions
  # to conform to the format mnw expects. end user should
  # only ever need to pass a list of packages, which are modified
  # here
  extraLuaPackages = ps: map (x: ps.${x}) vimOptions.luaPackages;
  extraPython3Packages = ps: map (x: ps.${x}) vimOptions.python3Packages;

  # Wrap the user's desired (unwrapped) Neovim package with arguments that'll be used to
  # generate a wrapped Neovim package.
  neovim-wrapped = inputs.mnw.lib.wrap pkgs {
    neovim = vimOptions.package;
    plugins = builtStartPlugins ++ builtOptPlugins;
    appName = "nvf";
    extraBinPath = vimOptions.extraPackages;
    initLua = vimOptions.builtLuaConfigRC;
    luaFiles = vimOptions.extraLuaFiles;

    inherit (vimOptions) viAlias vimAlias withRuby withNodeJs withPython3;
    inherit extraLuaPackages extraPython3Packages;
  };

  dummyInit = pkgs.writeText "nvf-init.lua" vimOptions.builtLuaConfigRC;
  # Additional helper scripts for printing and displaying nvf configuration
  # in your commandline.
  printConfig = pkgs.writers.writeDashBin "nvf-print-config" "cat ${dummyInit}";
  printConfigPath = pkgs.writers.writeDashBin "nvf-print-config-path" "echo -n ${dummyInit}";

  # Expose wrapped neovim-package for userspace
  # or module consumption.
  neovim = pkgs.symlinkJoin {
    name = "nvf-with-helpers";
    paths = [neovim-wrapped printConfig printConfigPath];
    postBuild = "echo Helpers added";

    # Allow evaluating vimOptions, i.e., config.vim from the packages' passthru
    # attribute. For example, packages.x86_64-linux.neovim.passthru.neovimConfig
    # will return the configuration in full.
    passthru.neovimConfig = vimOptions;

    meta =
      neovim-wrapped.meta
      // {
        description = "Wrapped Neovim package with helper scripts to print the config (path)";
      };
  };
in {
  config.vim.build = {
    finalPackage = neovim;
  };
}
