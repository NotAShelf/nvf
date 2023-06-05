{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.ui.modes-nvim = {
    enable = mkEnableOption "modes.nvim's prismatic line decorations";
  };
}
