{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) int str;
  inherit (lib.nvim.types) mkPluginSetupOption borderType;

  mkNotifyOpt = name: duration: hl_group: {
    duration = mkOption {
      type = int;
      default = duration;
      description = "The duration of the ${name} notification";
    };
    hl_group = mkOption {
      type = str;
      default = hl_group;
      description = "The highlight group of the ${name} notification";
    };
  };
in {
  options.vim.mini.notify = {
    enable = mkEnableOption "mini.notify";
    setupOpts = mkPluginSetupOption "mini.notify" {
      window.config.border = mkOption {
        type = borderType;
        default = config.vim.ui.borders.globalStyle;
        description = "The border type for the mini.notify-notifications";
      };
    };
    notifyOpts = mkPluginSetupOption "mini.notify notifications" {
      ERROR = mkNotifyOpt "error" 5000 "DiagnosticError";
      WARN = mkNotifyOpt "warn" 5000 "DiagnosticWarn";
      INFO = mkNotifyOpt "info" 5000 "DiagnosticInfo";
      DEBUG = mkNotifyOpt "debug" 0 "DiagnosticHint";
      TRACE = mkNotifyOpt "trace" 0 "DiagnosticOk";
      OFF = mkNotifyOpt "off" 0 "MiniNotifyNormal";
    };
  };
}
