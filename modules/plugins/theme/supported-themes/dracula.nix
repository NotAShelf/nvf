{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) bool;
  inherit (lib.nvim.types) mkPluginSetupOption;
  cfg = config.vim.theme;
in {
  dracula = {
    setupOpts = mkPluginSetupOption "dracula" {
      transparent_bg = mkOption {
        type = bool;
        default = cfg.transparent;
        internal = true;
      };
    };
    setup = ''
      require('dracula').load();
    '';
  };
}
