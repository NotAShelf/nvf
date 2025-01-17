{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
in {
  options.vim.mini.colors = {
    enable = mkEnableOption "mini.colors";
  };
}
