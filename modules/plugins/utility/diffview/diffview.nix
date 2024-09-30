{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.diffview-nvim = {
    enable = mkEnableOption "diffview-nvim: cycle through diffs for all modified files for any git rev";
    setupOpts = mkPluginSetupOption "Fidget" {};
  };
}
