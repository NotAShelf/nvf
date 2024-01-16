{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption;
in {
  options.vim.binds.cheatsheet = {
    enable = mkEnableOption "cheatsheet-nvim: searchable cheatsheet for nvim using telescope";
  };
}
