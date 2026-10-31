{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  mkMappingOption = config.vim.lib.mkMappingOption "Neogit";
in {
  options.vim.git.neogit = {
    enable = mkEnableOption "An Interactive and powerful Git interface [Neogit]";
    setupOpts = mkPluginSetupOption "neogit" {};

    mappings = {
      open = mkMappingOption "Git Status" "<leader>gs";
      commit = mkMappingOption "Git Commit" "<leader>gc";
      pull = mkMappingOption "Git pull" "<leader>gp";
      push = mkMappingOption "Git push" "<leader>gP";
    };
  };
}
