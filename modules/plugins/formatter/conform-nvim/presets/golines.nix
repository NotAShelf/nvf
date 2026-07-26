{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe';

  cfg = config.vim.formatter.conform-nvim.presets.golines;
in {
  options.vim.formatter.conform-nvim.presets.golines = {
    enable = mkFormatterPresetEnableOption {
      option = "golines";
      display = "Go";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.golines = {
      command = getExe' pkgs.go "golines";
    };
  };
}
