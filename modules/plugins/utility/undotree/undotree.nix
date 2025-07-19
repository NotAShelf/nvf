{ lib, ... }:
let
  inherit (lib.types) bool int;
  inherit (lib.options) mkEnableOption mkOption;

  inherit (lib.nvim.types) mkPluginSetupOption;
in
{
  options.vim.undotree = {
    enable = mkEnableOption "undotree";
    setupOpts = mkPluginSetupOption "undotree" {
      # enable_feature_a = mkOption {
      #   type = bool;
      #   default = false;
      #   # ...
      # };
      #
      # number_option = mkOption {
      #   type = int;
      #   default = 3;
      #   # ...
      # };
    };
  };
}
