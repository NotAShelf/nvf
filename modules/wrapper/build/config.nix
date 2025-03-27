{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs) vimPlugins;
  inherit (lib.trivial) flip;
  inherit (builtins) path filter isString;

  getPin = name: ((pkgs.callPackages ../../../npins/sources.nix {}) // config.vim.pluginOverrides).${name};

  noBuildPlug = pname: let
    pin = getPin pname;
    version = pin.revision or "dirty";
  in {
    # vim.lazy.plugins relies on pname, so we only set that here
    # version isn't needed for anything, but inherit it anyway for correctness
    inherit pname version;
    outPath = path {
      name = "${pname}-0-unstable-${version}";
      path = pin.outPath;
    };
    passthru.vimPlugin = false;
  };

  # build a vim plugin with the given name and arguments
  # if the plugin is nvim-treesitter, warn the user to use buildTreesitterPlug
  # instead
  buildPlug = attrs: let
    pin = getPin attrs.pname;
  in
    pkgs.vimUtils.buildVimPlugin (
      {
        version = pin.revision or "dirty";
        src = pin.outPath;
      }
      // attrs
    );

  buildTreesitterPlug = grammars: vimPlugins.nvim-treesitter.withPlugins (_: grammars);

  pluginBuilders = {
    nvim-treesitter = buildTreesitterPlug config.vim.treesitter.grammars;
    flutter-tools-patched = buildPlug {
      pname = "flutter-tools-nvim";
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
    inherit (inputs.self.legacyPackages.${pkgs.stdenv.system}) blink-cmp;
  };

  buildConfigPlugins = plugins:
    map (plug:
      if (isString plug)
      then pluginBuilders.${plug} or (noBuildPlug plug)
      else plug) (
      filter (f: f != null) plugins
    );

  # built (or "normalized") plugins that are modified
  builtStartPlugins = buildConfigPlugins config.vim.startPlugins;
  builtOptPlugins = map (package: package // {optional = true;}) (
    buildConfigPlugins config.vim.optPlugins
  );

  # Wrap the user's desired (unwrapped) Neovim package with arguments that'll be used to
  # generate a wrapped Neovim package.
  neovim-wrapped = inputs.mnw.lib.wrap pkgs {
    neovim = config.vim.package;
    plugins = builtStartPlugins ++ builtOptPlugins;
    appName = "nvf";
    extraBinPath = config.vim.extraPackages;
    initLua = config.vim.builtLuaConfigRC;
    luaFiles = config.vim.extraLuaFiles;
    providers = {
      python3 = {
        enable = config.vim.withPython3;
        extraPackages = ps: map (flip builtins.getAttr ps) config.vim.python3Packages;
      };
      ruby.enable = config.vim.withRuby;
      nodeJs.enable = config.vim.withNodeJs;
    };
    aliases = lib.optional config.vim.viAlias "vi" ++ lib.optional config.vim.vimAlias "vim";

    extraLuaPackages = ps: map (flip builtins.getAttr ps) config.vim.luaPackages;
  };

  dummyInit = pkgs.writeText "nvf-init.lua" config.vim.builtLuaConfigRC;
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

    # Allow evaluating config.vim, i.e., config.vim from the packages' passthru
    # attribute. For example, packages.x86_64-linux.neovim.passthru.neovimConfig
    # will return the configuration in full.
    passthru.neovimConfig = config.vim;

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
