{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.autocomplete = {
    enableSharedCmpSources = mkEnableOption "cmp sources that can work in nvim-cmp and blink.cmp";
  };
}
