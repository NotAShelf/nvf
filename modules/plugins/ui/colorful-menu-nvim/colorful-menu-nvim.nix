{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.ui.colorful-menu-nvim = {
    enable = mkEnableOption "treesitter highlighted completion menus [colorful-menu.nvim]";
    setupOpts = mkPluginSetupOption "colorful-menu-nvim" {};
  };
}
