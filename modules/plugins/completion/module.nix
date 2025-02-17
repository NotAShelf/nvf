{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.autocomplete = {
    enableSharedCmpSources = mkEnableOption "sources shared by blink.cmp and nvim-cmp";
  };
}
