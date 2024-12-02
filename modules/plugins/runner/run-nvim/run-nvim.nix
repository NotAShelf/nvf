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
        run = mkMappingOption "Run cached" "<leader>ri";
        runOverride = mkMappingOption "Run and override" "<leader>ro";
        runCommand = mkMappingOption "Run prompt" "<leader>rc";
      };
    };
  };
}
