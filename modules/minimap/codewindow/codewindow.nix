{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.minimap.codewindow = {
    enable = mkEnableOption "Enable codewindow plugin for minimap view";
  };
}
