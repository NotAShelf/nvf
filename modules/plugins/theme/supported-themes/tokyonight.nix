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
  tokyonight = {
    setupOpts = mkPluginSetupOption "tokyonight" {
      transparent = mkOption {
        type = bool;
        default = cfg.transparent;
        internal = true;
      };
    };
    setup = ''
      vim.cmd[[colorscheme tokyonight-${cfg.style}]]
    '';
    styles = ["night" "day" "storm" "moon"];
  };
}
