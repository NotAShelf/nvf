{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.binds.whichKey = {
    enable = mkEnableOption "Enable which-key keybind menu";
  };
}
