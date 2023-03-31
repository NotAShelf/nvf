{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.binds.cheatsheet = {
    enable = mkEnableOption "Searchable cheatsheet for nvim using telescope";
  };
}
