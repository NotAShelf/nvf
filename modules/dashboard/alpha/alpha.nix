{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.dashboard.alpha;
in {
  options.vim.dashboard.alpha = {
    enable = mkEnableOption "alpha";
  };
}
