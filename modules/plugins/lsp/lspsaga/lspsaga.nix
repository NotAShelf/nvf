{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.nvim.types) borderType mkPluginSetupOption;
  inherit (lib.nvim.lua) mkLuaInline;

  uiKindSetupOpts =
    if config.vim.theme.enable && config.vim.theme.name == "catppuccin"
    then {
      ui.kind = mkLuaInline ''
        require("catppuccin.groups.integrations.lsp_saga").custom_kind()
      '';
    }
    else {};
in {
  options.vim.lsp.lspsaga = {
    enable = mkEnableOption "LSP Saga";

    setupOpts =
      mkPluginSetupOption "lspsaga" {
        border_style = mkOption {
          type = borderType;
          default = config.vim.ui.borders.globalStyle;
          description = "Border type, see {command}`:help nvim_open_win`";
        };
      }
      // uiKindSetupOpts;
  };
}
