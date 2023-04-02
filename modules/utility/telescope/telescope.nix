{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.telescope = {
    enable = mkEnableOption "Enable multi-purpose telescope utility";
  };
}
