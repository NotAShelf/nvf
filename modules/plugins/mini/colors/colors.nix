{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.mini.colors = {
    enable = mkEnableOption "mini.colors";
  };
}
