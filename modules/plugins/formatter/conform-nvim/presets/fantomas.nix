{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.fantomas;
in {
  options.vim.formatter.conform-nvim.presets.fantomas = {
    enable = mkFormatterPresetEnableOption {
      option = "fantomas";
      display = "Fantomas";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.fantomas = {
      command = "${pkgs.fantomas}/bin/fantomas";
    };
  };
}
