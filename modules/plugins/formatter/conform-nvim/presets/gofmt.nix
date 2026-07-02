{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.gofmt;
in {
  options.vim.formatter.conform-nvim.presets.gofmt = {
    enable = mkFormatterPresetEnableOption {
      option = "gofmt";
      display = "Go";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.gofmt = {
      command = "${pkgs.go}/bin/gofmt";
    };
  };
}
