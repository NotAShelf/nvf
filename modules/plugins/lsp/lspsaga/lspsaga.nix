{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkRemovedOptionModule;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.nvim.types) borderType mkPluginSetupOption;
in {
  imports = [
    (mkRemovedOptionModule ["vim" "lsp" "lspsaga" "mappings"] ''
      Lspsaga mappings have been removed from nvf, as the original author has made
      very drastic changes to the API after taking back ownership, and the fork we
      used is now archived. Please refer to Lspsaga documentation to add keybinds
      for functionality you have used.

      <https://nvimdev.github.io/lspsaga>
    '')
  ];

  options.vim.lsp.lspsaga = {
    enable = mkEnableOption "LSP Saga";

    setupOpts = mkPluginSetupOption "lspsaga" {
      border_style = mkOption {
        type = borderType;
        default = config.vim.ui.borders.globalStyle;
        description = "Border type, see {command}`:help nvim_open_win`";
      };
    };
  };
}
