{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.vim.notify.nvim-notify = {
    enable = mkEnableOption "nvim-notify notifications";
    stages = mkOption {
      type = types.enum ["fade_in_slide_out" "fade_in" "slide_out" "none"];
      default = "fade_in_slide_out";
      description = "The stages of the notification";
    };

    timeout = mkOption {
      type = types.int;
      default = 1000;
      description = "The timeout of the notification";
    };

    background_colour = mkOption {
      type = types.str;
      default = "#000000";
      description = "The background colour of the notification";
    };

    position = mkOption {
      type = types.enum ["top_left" "top_right" "bottom_left" "bottom_right"];
      default = "top_right";
      description = "The position of the notification";
    };

    icons = mkOption {
      type = types.attrsOf types.str;
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
