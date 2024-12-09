{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.lsp = {
    lightbulb = {
      enable = mkEnableOption "Lightbulb for code actions. Requires an emoji font";
      setupOpts = mkPluginSetupOption "nvim-lightbulb" {};
    };
  };
}
