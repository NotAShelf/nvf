{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs) vimPlugins;
  inherit (lib.trivial) flip;
  inherit (builtins) filter isString hasAttr getAttr;

  getPin = flip getAttr (inputs.mnw.lib.npinsToPluginsAttrs pkgs ../../../npins/sources.json);

  # Build a Vim plugin with the given name and arguments.
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

  # Build a given Treesitter grammar.
  buildTreesitterPlug = grammars: vimPlugins.nvim-treesitter.withPlugins (_: grammars);

  pluginBuilders = {
    nvim-treesitter = buildTreesitterPlug config.vim.treesitter.grammars;
    flutter-tools-patched = buildPlug {
      pname = "flutter-tools-nvim";
      patches = [./patches/flutter-tools.patch];

      # Disable failing require check hook checks
      doCheck = false;
    };
    # Checkhealth fails to get the plugin's commit and therefore to
    # show the rest of the useful diagnostics if not built like this.
    obsidian-nvim = pkgs.vimUtils.buildVimPlugin {
      # If set to `"obsidian-nvim"`, this breaks like `buildPlug` and .
      name = "obsidian.nvim";
      src = getPin "obsidian-nvim";
      nvimSkipModules = [
        "minimal"
        # require picker plugins
        "obsidian.picker._telescope"
        "obsidian.picker._snacks"
        "obsidian.picker._fzf"
        "obsidian.picker._mini"
      ];
    };

    # Get plugins built from source from self.packages
    # If adding a new plugin to be built from source, it must also be inherited
    # here.
    inherit (inputs.self.packages.${pkgs.stdenv.system}) blink-cmp avante-nvim;
  };

  buildConfigPlugins = plugins:
    map (plug:
      if (isString plug)
      then
        if hasAttr plug config.vim.pluginOverrides
        then
          (let
            plugin = config.vim.pluginOverrides.${plug};
          in
            if (lib.isType "flake" plugin)
            then plugin // {name = plug;}
            else plugin)
        else pluginBuilders.${plug} or (getPin plug)
      else plug) (
      filter (f: f != null) plugins
    );

  # Wrap the user's desired (unwrapped) Neovim package with arguments that'll be used to
  # generate a wrapped Neovim package.
  neovim-wrapped = inputs.mnw.lib.wrap {inherit pkgs;} {
    appName = "nvf";
    neovim = config.vim.package;
    initLua = config.vim.builtLuaConfigRC;
    luaFiles = config.vim.extraLuaFiles;

    # Plugin configurations
    plugins = {
      start = buildConfigPlugins config.vim.startPlugins;
      opt = buildConfigPlugins config.vim.optPlugins;
    };

    # Providers for Neovim
    providers = {
      ruby.enable = config.vim.withRuby;
      nodeJs.enable = config.vim.withNodeJs;
      python3 = {
        enable = config.vim.withPython3;
        extraPackages = ps: (map (flip builtins.getAttr ps) config.vim.python3Packages) ++ [ps.pynvim];
      };
    };

    # Aliases to link `nvim` to
    aliases = lib.optional config.vim.viAlias "vi" ++ lib.optional config.vim.vimAlias "vim";

    # Additional packages or Lua packages to be made available to Neovim
    extraBinPath = config.vim.extraPackages;
    extraLuaPackages = ps: map (flip builtins.getAttr ps) config.vim.luaPackages;
  };

  # A store path representing the built Lua configuration.
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

    passthru = {
      # Allow evaluating config.vim, i.e., config.vim from the packages' passthru
      # attribute. For example, packages.x86_64-linux.neovim.passthru.neovimConfig
      # will return the configuration in full.
      neovimConfig = config.vim;

      # Also expose the helper scripts in passthru.
      nvfPrintConfig = printConfig;
      nvfPrintConfigPath = printConfigPath;

      # In systems where we only have a package and no module, this can be used
      # to access the built init.lua
      initLua = dummyInit;

      mnwConfig = neovim-wrapped.passthru.config;
      mnwConfigDir = neovim-wrapped.passthru.configDir;
    };

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
