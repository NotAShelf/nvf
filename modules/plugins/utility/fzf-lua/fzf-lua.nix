{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption borderType;
in {
  options.vim.fzf-lua = {
    enable = mkEnableOption "fzf-lua";
    setupOpts = mkPluginSetupOption "mini.ai" {
      winopts.border = mkOption {
        type = borderType;
        default = config.vim.ui.borders.globalStyle;
      };
    };
  };
}
