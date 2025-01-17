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
        description = "The background color to use";
        type = hexColor;
        apply = v:
          if hasPrefix "#" v
          then v
          else "#${v}";
      };

      foreground = mkOption {
        description = "The foreground color to use";
        type = hexColor;
        apply = v:
          if hasPrefix "#" v
          then v
          else "#${v}";
      };
    };
  };
}
