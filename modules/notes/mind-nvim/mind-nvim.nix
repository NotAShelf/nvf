{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.notes.mind-nvim = {
    enable = mkEnableOption "The power of trees at your fingertips. ";
  };
}
