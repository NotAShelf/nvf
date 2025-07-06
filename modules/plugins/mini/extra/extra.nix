{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.mini.extra = {
    enable = mkEnableOption "mini.extra";
  };
}
