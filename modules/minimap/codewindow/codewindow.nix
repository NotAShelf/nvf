{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.minimap.codewindow = {
    enable = mkEnableOption "Enable minimap-vim plugin";
  };
}
