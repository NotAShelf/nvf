{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.utility.colorizer;
in {
  options.vim.utility.colorizer = {
    enable = mkEnableOption "ccc color picker for neovim";
  };
}
