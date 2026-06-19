{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.styler;
in {
  options.vim.formatter.conform-nvim.presets.styler = {
    enable = mkFormatterPresetEnableOption {
      option = "styler";
      display = "`styler`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.styler = {
      command = "${pkgs.rWrapper.override {packages = [pkgs.rPackages.styler];}}/bin/R";
    };
  };
}
