{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
in {
  options.vim.mini.extra = {
    enable = mkEnableOption "mini.extra";
  };
}
