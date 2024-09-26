{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) attrs;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.formatter.conform-nvim = {
    enable = mkEnableOption "lightweight yet powerful formatter plugin for Neovim [conform-nvim]";
    setupOpts = mkPluginSetupOption "conform.nvim" {
      formatters_by_ft = mkOption {
        type = attrs;
        default = {};
        example = literalExpression "lua = [\"${pkgs.stylua}/bin/stylua\"]";
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
    };
  };
}
