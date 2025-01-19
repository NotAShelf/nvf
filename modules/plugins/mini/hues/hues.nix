{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.strings) hasPrefix;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (lib.nvim.types) hexColor;
in {
  options.vim.mini.hues = {
    enable = mkEnableOption "mini.hues";
    setupOpts = mkPluginSetupOption "mini.hues" {
      background = mkOption {
        description = "The hex color for the background color of the color scheme, prefixed with #";
        type = hexColor;
      };

      foreground = mkOption {
        description = "The hex color for the foreground color of the color scheme, prefixed with #";
        type = hexColor;
      };
    };
  };
}
