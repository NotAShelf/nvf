{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.binds.cheatsheet;
in {
  options.vim.binds.cheatsheet = {
    enable = mkEnableOption "Searchable cheatsheet for nvim using telescope";
  };
}
