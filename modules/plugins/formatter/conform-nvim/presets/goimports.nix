{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.goimports;
in {
  options.vim.formatter.conform-nvim.presets.goimports = {
    enable = mkFormatterPresetEnableOption {
      option = "goimports";
      display = "Go Imports";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.goimports = {
      command = "${pkgs.gotools}/bin/goimports";
    };
  };
}
