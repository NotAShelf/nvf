{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.utility.mkdir.enable = mkEnableOption ''
    parent directory creation when editing a nested path that does not exist using `mkdir.nvim`
  '';
}
