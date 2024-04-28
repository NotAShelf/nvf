{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.ui.illuminate = {
    enable = mkEnableOption "automatically highlight other uses of the word under the cursor [vim-illuminate]";
  };
}
