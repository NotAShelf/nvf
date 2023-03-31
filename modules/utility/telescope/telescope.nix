{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.telescope = {
    enable = mkEnableOption "enable telescope";
  };
}
