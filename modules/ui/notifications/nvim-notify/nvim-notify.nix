{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) enum int str attrsOf;
in {
  options.vim.notify.nvim-notify = {
    enable = mkEnableOption "nvim-notify notifications";
    stages = mkOption {
      type = enum ["fade_in_slide_out" "fade_in" "slide_out" "none"];
      default = "fade_in_slide_out";
      description = "The stages of the notification";
    };

    timeout = mkOption {
      type = int;
      default = 1000;
      description = "The timeout of the notification";
    };

    background_colour = mkOption {
      type = str;
      default = "#000000";
      description = "The background colour of the notification";
    };

    position = mkOption {
      type = enum ["top_left" "top_right" "bottom_left" "bottom_right"];
      default = "top_right";
      description = "The position of the notification";
    };

    icons = mkOption {
      type = attrsOf str;
      description = "The icons of the notification";
      default = {
        ERROR = "";
        WARN = "";
        INFO = "";
        DEBUG = "";
        TRACE = "";
      };
    };
  };
}
