{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.minimap.minimap-vim = {
    enable = mkEnableOption "Enable minimap-vim plugin for minimap view";
  };
}
