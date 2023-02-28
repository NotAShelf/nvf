{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.utility.icon-picker;
in {
  options.vim.utility.icon-picker = {
    enable = mkEnableOption "Nerdfonts icon picker for nvim";
  };
}
