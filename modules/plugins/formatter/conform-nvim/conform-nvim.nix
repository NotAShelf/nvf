{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) attrsOf anything listOf either;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;

  cfg = config.vim.formatter.conform-nvim;
in {
  options.vim.formatter.conform-nvim = {
    enable = mkEnableOption "lightweight yet powerful formatter plugin for Neovim [conform-nvim]";

    # This is to declare all custom formatters nvf uses for language modules in a single
    # module option so that
    #  1. Modules can refer to each others' formatters
    #  2. If users already have some of the formatters in PATH, they can override the attrset.
    # Values set here will be passed directly to setupOpts.formatters.
    configuredFormatters = mkOption {
      type = attrsOf anything;
      default = {};
      example = literalExpression ''
        {
          yamlfix.command = "$${lib.getExe pkgs.yamlfix}";
          rustfmt.env = {
            RUST_SRC_PATH = "$${pkgs.rustPlatform.rustLibSrc}";
          };
        }
      '';
      description = "Override options for formatters provided by conform.nvim";
    };

    setupOpts = mkPluginSetupOption "conform.nvim" {
      formatters = mkOption {
        type = attrsOf anything;
        default = cfg.configuredFormatters;
        description = ''
          Attribute set containing overrides for conform's own formatters, or
          new formatters to be recognized by conform in, e.g., `formatters_by_ft`
        '';
      };

      formatters_by_ft = mkOption {
        type = either (attrsOf (listOf anything)) luaInline;
        default = {};
        example = {lua = ["stylua"];};
        description = ''
          Map of filetype to formatters. This option takes a set of
          `key = value` format where the `value will` be converted
          to its Lua equivalent. You are responsible for passing the
          correct Nix data types to generate a correct Lua value that
          conform is able to accept.
        '';
      };

      default_format_opts = mkOption {
        type = attrsOf anything;
        default = {lsp_format = "fallback";};
        description = "Default values when calling `conform.format()`";
      };

      format_on_save = mkOption {
        type = attrsOf anything;
        default = {
          lsp_format = "fallback";
          timeout_ms = 500;
        };
        description = ''
          Table that will be passed to `conform.format()`. If this
          is set, Conform will run the formatter on save.
        '';
      };

      format_after_save = mkOption {
        type = attrsOf anything;
        default = {lsp_format = "fallback";};
        description = ''
          Table that will be passed to `conform.format()`. If this
          is set, Conform will run the formatter asynchronously after
          save.
        '';
      };
    };
  };
}
