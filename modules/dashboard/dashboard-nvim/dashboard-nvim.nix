{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.dashboard.dashboard-nvim;
in {
  options.vim.dashboard.dashboard-nvim = {
    enable = mkEnableOption "dashboard-nvim";
  };
}
