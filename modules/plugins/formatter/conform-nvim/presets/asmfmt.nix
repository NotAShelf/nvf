{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.formatter.conform-nvim.presets.asmfmt;
in {
  options.vim.formatter.conform-nvim.presets.asmfmt = {
    enable = mkFormatterPresetEnableOption {
      option = "asmfmt";
      display = "Go Assembler";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.asmfmt = {
      command = getExe pkgs.asmfmt;
      stdin = true;
    };
  };
}
