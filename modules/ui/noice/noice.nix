{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.ui.noice = {
    enable = mkEnableOption "noice.nvim UI modification library";
  };
}
