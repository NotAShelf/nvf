{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs) vimPlugins;
  inherit (lib.trivial) flip;
  inherit (builtins) filter isString;

  getPin = name: ((pkgs.callPackages ../../../npins/sources.nix {}) // config.vim.pluginOverrides).${name};

  # HACK: this is so fucking ass someone please rewrite this
  noBuildPlug = pname: let
    pin = getPin pname;
    pinVersion = builtins.substring 0 8 pin.revision;
    drvVersion =
      pin.version or (
        if pin ? rev
        then builtins.substring 0 8 pin.rev
        else "dirty"
      );
  in
    if pin ? type && pin.type == "derivation"
    then # a derivation, hopefully from a fetcher
      pin.overrideAttrs {
        inherit pname;
        version = drvVersion;
        # the name from various fetchers tend to be "source"
        name = "${pname}-${drvVersion}";

        passthru.vimPlugin = false;
      }
    else if pin ? type
    then # npins source
      # there's a set list of possible values for pin.type so maybe I should
      # check that
      pin.outPath.overrideAttrs {
        inherit pname;
        version = pinVersion;
        name = "${pname}-${pinVersion}";

        passthru.vimPlugin = false;
      }
    else # flake inputs with flake=false are not derivations
      # should I detect bad inputs? maybe, but I have no fucking clue what I'm
      # doing here
      # Is this how you normally do a no-build? idfk
      pkgs.stdenv.mkDerivation {
        inherit pname;
        version = pin.rev or "dirty";
        src = pin;
        dontBuild = true;
        installPhase = ''
          cp -r . $out
        '';

        passthru.vimPlugin = false;
      };

  # build a vim plugin with the given name and arguments
  buildPlug = attrs: let
    pin = getPin attrs.pname;
    src =
      if pin ? type -> pin.type == "derivation"
      # derivation or flake input, I hope
      then pin
      # npins source
      else pin.outPath;
  in
    pkgs.vimUtils.buildVimPlugin (
      {
        # pin.revision is for npins, pin.rev for result from fetchers
        version = pin.revision or pin.rev or "dirty";
        inherit src;
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
      doCheck = false;
    };

    inherit (inputs.self.packages.${pkgs.stdenv.system}) blink-cmp avante-nvim;
  };

  buildConfigPlugins = plugins:
    map (plug:
      if (isString plug)
      then pluginBuilders.${plug} or (noBuildPlug plug)
      else plug) (
      filter (f: f != null) plugins
    );

  # Wrap the user's desired (unwrapped) Neovim package with arguments that'll be used to
  # generate a wrapped Neovim package.
  neovim-wrapped = inputs.mnw.lib.wrap {inherit pkgs;} {
    neovim = config.vim.package;
    plugins = {
      start = buildConfigPlugins config.vim.startPlugins;
      opt = buildConfigPlugins config.vim.optPlugins;
    };
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
