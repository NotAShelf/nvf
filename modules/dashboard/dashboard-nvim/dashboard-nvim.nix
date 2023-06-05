{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.dashboard.dashboard-nvim = {
    enable = mkEnableOption "dashboard via dashboard.nvim";
  };
}
