{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) attrsOf str int;
in {
  options.vim.lsp.null-ls = {
    enable = mkEnableOption "null-ls, also enabled automatically";

    debug = mkEnableOption "debugging information for `null-ls";

    diagnostics_format = mkOption {
      type = str;
      default = "[#{m}] #{s} (#{c})";
      description = "Diagnostic output format for null-ls";
    };

    debounce = mkOption {
      type = int;
      default = 250;
      description = "Default debounce";
    };

    default_timeout = mkOption {
      type = int;
      default = 5000;
      description = "Default timeout value, in milliseconds";
    };

    sources = mkOption {
      description = "null-ls sources";
      type = attrsOf str;
      default = {};
    };
  };
}
