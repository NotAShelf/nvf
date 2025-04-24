{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.utility.sleuth.enable = mkEnableOption ''
    automatically adjusting options such as `shiftwidth` or `expandtab`, using `vim-sleuth`
  '';
}
