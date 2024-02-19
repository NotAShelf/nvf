{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.dashboard.alpha = {
    enable = mkEnableOption "dashboard [alpha-nvim]";
  };
}
