{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool;
  inherit (lib.nvim.types) mkPluginSetupOption;
  mkMappingOption = config.vim.lib.mkMappingOption "yazi.nvim";
in {
  options.vim.utility.yazi-nvim = {
    enable = mkEnableOption ''
      companion plugin for the yazi terminal file manager [yazi-nvim]
    '';

    mappings = {
      openYazi = mkMappingOption "Open yazi at the current file" "<leader>-";
      openYaziDir = mkMappingOption "Open the file manager in nvim's working directory" "<leader>cw";
      yaziToggle = mkMappingOption "Resume the last yazi session" "<c-up>";
    };

    setupOpts = mkPluginSetupOption "yazi-nvim" {
      open_for_directories = mkOption {
        type = bool;
        default = false;
        description = "Whether to open Yazi instead of netrw";
      };
    };
  };
}
