{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.bean-format;
in {
  options.vim.formatter.conform-nvim.presets.bean-format = {
    enable = mkFormatterPresetEnableOption {
      option = "bean-format";
      display = "Bean Format";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.bean-format = {
      command = "${pkgs.beancount}/bin/bean-format";
    };
  };
}
