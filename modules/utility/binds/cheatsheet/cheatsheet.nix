{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.binds.cheatsheet = {
    enable = mkEnableOption "cheatsheet-nvim: searchable cheatsheet for nvim using telescope";
  };
}
