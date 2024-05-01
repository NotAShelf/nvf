{lib, ...}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) str;
in {
  options.vim.ui.icons = {
    ERROR = mkOption {
      type = str;
      default = " ";
      description = "The icon to use for error messages";
    };

    WARN = mkOption {
      type = str;
      default = " ";
      description = "The icon to use for warning messages";
    };

    INFO = mkOption {
      type = str;
      default = " ";
      description = "The icon to use for info messages";
    };

    HINT = mkOption {
      type = str;
      default = " ";
      description = "The icon to use for hint messages";
    };
  };
}
