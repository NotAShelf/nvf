{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.treesitter.textobjects = {
    enable = mkEnableOption "Treesitter textobjects";
    setupOpts = mkPluginSetupOption "treesitter-textobjects" {};
  };
}
