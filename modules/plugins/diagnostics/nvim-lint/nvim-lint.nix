{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) attrs attrsOf listOf str;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.diagnostics.nvim-lint = {
    enable = mkEnableOption "asynchronous linter plugin for Neovim [nvim-lint]";
    setupOpts = mkPluginSetupOption "conform.nvim" {
      linters_by_ft = mkOption {
        type = attrsOf (listOf str);
        default = {};
        example = {
          text = ["vale"];
          markdown = ["vale"];
        };
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
