{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.filetree.nvimTree = {
    enable = mkEnableOption "filetree via neo-tree.nvim";
    setupOpts = mkPluginSetupOption "neo-tree" {};
  };
}
