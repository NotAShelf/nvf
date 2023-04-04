{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.ui.modes-nvim = {
    enable = mkEnableOption "Enable modes.nvim UI elements";
  };
}
