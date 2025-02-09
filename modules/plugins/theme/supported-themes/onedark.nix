{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) str;
  inherit (lib.nvim.types) mkPluginSetupOption;
  cfg = config.vim.theme;
in {
  onedark = {
    setupOpts = mkPluginSetupOption "onedark" {
      style = mkOption {
        type = str;
        default = cfg.style;
        internal = true;
      };
    };
    setup = ''
      -- OneDark theme
      require('onedark').load()
    '';
    styles = ["dark" "darker" "cool" "deep" "warm" "warmer"];
  };
}
