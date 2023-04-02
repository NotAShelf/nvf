{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.dashboard.alpha = {
    enable = mkEnableOption "Enable alpha.nvim";
  };
}
