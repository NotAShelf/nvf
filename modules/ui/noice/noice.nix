{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  options.vim.ui.noice = {
    enable = mkEnableOption "UI modification library [noice.nvim]";
  };
}
