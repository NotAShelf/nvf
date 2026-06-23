{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.utility.dadbod = {
    enable = mkEnableOption "modern database interface for Vim [vim-dadbod]";
  };
}
