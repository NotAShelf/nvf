{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.utility.visual-multi = {
    enable = mkEnableOption "multiple cursors capability [visual-multi.nvim]";
  };
}
