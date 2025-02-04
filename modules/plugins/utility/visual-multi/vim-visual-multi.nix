{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.utility.visual-multi = {
    enable = mkEnableOption "visual-multi.nvim plugin (multiple cursors)";
  };
}
