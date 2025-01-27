{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) bool str;
  inherit (lib.nvim.types) mkPluginSetupOption;
  cfg = config.vim.theme;

  mkEnableOption' = name: mkEnableOption name // {default = true;};
in {
  rose-pine = {
    setupOpts = mkPluginSetupOption "rose-pine" {
      dark_variant = mkOption {
        type = str;
        default = cfg.style;
        internal = true;
      };
      dim_inactive_windows = mkEnableOption "dim_inactive_windows";
      extend_background_behind_borders = mkEnableOption' "extend_background_behind_borders";

      enable = {
        terminal = mkEnableOption' "terminal";
        migrations = mkEnableOption' "migrations";
      };

      styles = {
        bold = mkEnableOption "bold";
        # I would like to add more options for this
        italic = mkEnableOption "italic";
        transparency = mkOption {
          type = bool;
          default = cfg.transparent;
          internal = true;
        };
      };
    };

    setup = ''
      vim.cmd("colorscheme rose-pine")
    '';
    styles = ["main" "moon" "dawn"];
  };
}
