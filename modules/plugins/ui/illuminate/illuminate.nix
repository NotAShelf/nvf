{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption;
in {
  options.vim.ui.illuminate = {
    enable = mkEnableOption "vim-illuminate: automatically highlight other uses of the word under the cursor";
  };
}
