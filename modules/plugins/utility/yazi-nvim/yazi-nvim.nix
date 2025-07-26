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
      openYazi = mkMappingOption config.vim.enableNvfKeymaps "Open yazi at the current file [yazi.nvim]" "<leader>-";
      openYaziDir = mkMappingOption config.vim.enableNvfKeymaps "Open the file manager in nvim's working directory [yazi.nvim]" "<leader>cw";
      yaziToggle = mkMappingOption config.vim.enableNvfKeymaps "Resume the last yazi session [yazi.nvim]" "<c-up>";
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
