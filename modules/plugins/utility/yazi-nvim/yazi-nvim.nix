{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  options.vim.utility.yazi-nvim = {
    enable = mkEnableOption ''
      companion plugin for the yazi terminal file manager [yazi-nvim]
    '';

    mappings = {
      openYazi = mkMappingOption "Open yazi at the current file [yazi.nvim]" "<leader>-";
      openYaziDir = mkMappingOption "Open the file manager in nvim's working directory [yazi.nvim]" "<leader>cw";
      yaziToggle = mkMappingOption "Resume the last yazi session [yazi.nvim]" "<c-up>";
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
