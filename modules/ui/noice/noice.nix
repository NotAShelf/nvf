{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.ui.noice = {
    enable = mkEnableOption "Enable noice-nvim UI modifications";
  };
}
