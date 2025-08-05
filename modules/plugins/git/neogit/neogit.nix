{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.git.neogit = {
    enable = mkEnableOption "An Interactive and powerful Git interface [Neogit]";
    setupOpts = mkPluginSetupOption "neogit" {};

    mappings = {
      open = mkMappingOption "Git Status [Neogit]" "<leader>gs";
      commit = mkMappingOption "Git Commit [Neogit]" "<leader>gc";
      pull = mkMappingOption "Git pull [Neogit]" "<leader>gp";
      push = mkMappingOption "Git push [Neogit]" "<leader>gP";
    };
  };
}
