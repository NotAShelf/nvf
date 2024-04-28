{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.types) int str enum attrsOf either;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
in {
  imports = let
    renamedSetupOpt = name:
      mkRenamedOptionModule
      ["vim" "notify" "nvim-notify" name]
      ["vim" "notify" "nvim-notify" "setupOpts" name];
  in [
    (renamedSetupOpt "stages")
    (renamedSetupOpt "timeout")
    (renamedSetupOpt "background_colour")
    (renamedSetupOpt "position")
    (renamedSetupOpt "icons")
  ];

  options.vim.notify.nvim-notify = {
    enable = mkEnableOption "nvim-notify notifications";

    setupOpts = mkPluginSetupOption "nvim-notify" {
      render = mkOption {
        type = either (enum ["default" "minimal" "simple" "compact" "wrapped-compact"]) luaInline;
        default = "compact";
        description = "Custom rendering method to be used for displaying notifications";
      };

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
          TRACE = "";
        };
      };
    };
  };
}
