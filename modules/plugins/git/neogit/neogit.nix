{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.git.neogit = {
    enable = mkEnableOption "An Interactive and powerful Git interface [Neogit]";
    setupOpts = mkPluginSetupOption "neogit" {};

    mappings = {
      open = mkMappingOption config.vim.enableNvfKeymaps "Git Status [Neogit]" "<leader>gs";
      commit = mkMappingOption config.vim.enableNvfKeymaps "Git Commit [Neogit]" "<leader>gc";
      pull = mkMappingOption config.vim.enableNvfKeymaps "Git pull [Neogit]" "<leader>gp";
      push = mkMappingOption config.vim.enableNvfKeymaps "Git push [Neogit]" "<leader>gP";
    };
  };
}
