{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption literalMD;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.types) enum listOf attrsOf str;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.attrsets) listToAttrs attrNames;
  inherit (builtins) concatMap map;

  cfg = config.vim.formatter.conform-nvim.presets.prettier;

  plugins = let
    astro = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.prettier-plugin-astro;
    svelte = inputs.self.packages.${pkgs.stdenv.system}.prettier-plugin-svelte;
    pug = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.prettier-plugin-pug;
  in {
    astro = {
      plugin = "${astro}/index.js";
      filetypes = ["astro"];
    };
    svelte = {
      plugin = "${svelte}/lib/node_modules/prettier-plugin-svelte/plugin.js";
      filetypes = ["svelte"];
    };
    pug = {
      plugin = "${pug}/index.js";
      filetypes = ["pug"];
    };
  };
in {
  options.vim.formatter.conform-nvim.presets.prettier = {
    enable = mkFormatterPresetEnableOption {
      option = "prettier";
      display = "Prettier";
    };

    plugins = mkOption {
      type = listOf (enum (attrNames plugins));
      default = [];
      description = ''
        Extra Prettier plugins to load.

        Plugins will only be loaded on their defined filetypes by default.
        This can be overridden via {option}`vim.formatter.conform-nvim.presets.prettier.filetypeParsers`
      '';
    };

    filetypeParser = mkOption {
      type = attrsOf str;
      default = listToAttrs (concatMap
        (name:
          map (filetype: {
            name = filetype;
            value = name;
          })
          plugins.${name}.filetypes)
        cfg.plugins);
      defaultText = literalMD ''
        Matching filetypes and parsers for the registered
        `config.vim.formatter.conform-nvim.presets.prettier.plugins`.
      '';
      description = ''
        By default prettier infers the parser to use automatically from the file name.
        This option allows to override that.

        See more about this upstream:
        <https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/prettier.lua#L32>
      '';
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.prettier = {
      # extends <https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/prettier.lua>
      command = "${pkgs.prettier}/bin/prettier";

      # Due to the way conform does the parser options, we can always register the filetype parser,
      # even when we didn't load the plugin. This allows us to precompute this map.
      # <https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/prettier.lua#L32>
      options.ft_parsers = cfg.filetypeParser;

      # dynamically load the required plugins
      prepend_args = let
        args = listToAttrs (concatMap
          (name:
            map (filetype: {
              name = filetype;
              value = ["--plugin=${plugins.${name}.plugin}"];
            })
            plugins.${name}.filetypes)
          cfg.plugins);
      in
        mkLuaInline ''
          function(self, ctx)
            return (${toLuaObject args})[vim.bo[ctx.buf].filetype] or {}
          end
        '';
    };
  };
}
