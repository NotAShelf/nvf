{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) attrs nullOr;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.formatter.conform-nvim = {
    enable = mkEnableOption "lightweight yet powerful formatter plugin for Neovim [conform-nvim]";
    setupOpts = mkPluginSetupOption "conform.nvim" {
      formatters_by_ft = mkOption {
        type = attrs;
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
        type = attrs;
        default = {lsp_format = "fallback";};
        description = "Default values when calling `conform.format()`";
      };

      format_on_save = mkOption {
        type = nullOr attrs;
        default =
          if config.vim.lsp.formatOnSave
          then {
            lsp_format = "fallback";
            timeout_ms = 500;
          }
          else null;
        description = ''
          Table that will be passed to `conform.format()`. If this
          is set, Conform will run the formatter on save.
        '';
      };

      format_after_save = mkOption {
        type = nullOr attrs;
        default =
          if config.vim.lsp.formatOnSave
          then {lsp_format = "fallback";}
          else null;
        description = ''
          Table that will be passed to `conform.format()`. If this
          is set, Conform will run the formatter asynchronously after
          save.
        '';
      };
    };
  };
}
