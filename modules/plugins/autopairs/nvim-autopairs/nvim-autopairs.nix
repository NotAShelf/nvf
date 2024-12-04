{lib, ...}: let
  inherit (lib) mkRemovedOptionModule;
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  imports = [
    (mkRemovedOptionModule ["vim" "autopairs" "nvim-compe"] "nvim-compe is deprecated and no longer supported.")
  ];

  options.vim.autopairs.nvim-autopairs = {
    enable = mkEnableOption "autopairs";
    setupOpts = mkPluginSetupOption "nvim-autopairs" {};
  };
}
