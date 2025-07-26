{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  options = {
    vim.runner.run-nvim = {
      enable = mkEnableOption "run.nvim";
      setupOpts = mkPluginSetupOption "run.nvim" {};

      mappings = {
        run = mkMappingOption config.vim.enableNvfKeymaps "Run cached" "<leader>ri";
        runOverride = mkMappingOption config.vim.enableNvfKeymaps "Run and override" "<leader>ro";
        runCommand = mkMappingOption config.vim.enableNvfKeymaps "Run prompt" "<leader>rc";
      };
    };
  };
}
