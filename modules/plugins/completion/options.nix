{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) listOf;
  inherit (lib.nvim.types) pluginType;
in {
  options.vim.autocomplete = {
    enableSharedCmpSources = mkEnableOption "cmp sources shared by nvim-cmp and blink.cmp";

    cmpSourcePlugins = mkOption {
      type = listOf pluginType;
      default = [];
      description = "List of cmp source plugins.";
    };
  };
}
