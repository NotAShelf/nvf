{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  mkMappingOption = config.vim.lib.mkMappingOption "Git-Conflict";
in {
  options.vim.git.git-conflict = {
    enable = mkEnableOption "git-conflict" // {default = config.vim.git.enable;};
    setupOpts = mkPluginSetupOption "git-conflict" {};

    mappings = {
      ours = mkMappingOption "Choose Ours" "<leader>co";
      theirs = mkMappingOption "Choose Theirs" "<leader>ct";
      both = mkMappingOption "Choose Both" "<leader>cb";
      none = mkMappingOption "Choose None" "<leader>c0";
      prevConflict = mkMappingOption "Go to the previous Conflict" "]x";
      nextConflict = mkMappingOption "Go to the next Conflict" "[x";
    };
  };
}
