{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.ui.noice = {
    enable = mkEnableOption "UI modification library [noice.nvim]";
  };
}
