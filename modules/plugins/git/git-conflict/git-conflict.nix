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
      ours = mkMappingOption "Choose Ours [Git-Conflict]" "<leader>co";
      theirs = mkMappingOption "Choose Theirs [Git-Conflict]" "<leader>ct";
      both = mkMappingOption "Choose Both [Git-Conflict]" "<leader>cb";
      none = mkMappingOption "Choose None [Git-Conflict]" "<leader>c0";
      prevConflict = mkMappingOption "Go to the previous Conflict [Git-Conflict]" "]x";
      nextConflict = mkMappingOption "Go to the next Conflict [Git-Conflict]" "[x";
    };
  };
}
