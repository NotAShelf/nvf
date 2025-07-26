{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.git.git-conflict = {
    enable = mkEnableOption "git-conflict" // {default = config.vim.git.enable;};
    setupOpts = mkPluginSetupOption "git-conflict" {};

    mappings = {
      ours = mkMappingOption config.vim.enableNvfKeymaps "Choose Ours [Git-Conflict]" "<leader>co";
      theirs = mkMappingOption config.vim.enableNvfKeymaps "Choose Theirs [Git-Conflict]" "<leader>ct";
      both = mkMappingOption config.vim.enableNvfKeymaps "Choose Both [Git-Conflict]" "<leader>cb";
      none = mkMappingOption config.vim.enableNvfKeymaps "Choose None [Git-Conflict]" "<leader>c0";
      prevConflict = mkMappingOption config.vim.enableNvfKeymaps "Go to the previous Conflict [Git-Conflict]" "]x";
      nextConflict = mkMappingOption config.vim.enableNvfKeymaps "Go to the next Conflict [Git-Conflict]" "[x";
    };
  };
}
