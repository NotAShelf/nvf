{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption;
in {
  options.vim.dashboard.dashboard-nvim = {
    enable = mkEnableOption "dashboard via dashboard.nvim";
  };
}
