{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.formatter.conform-nvim.presets.buf;
in {
  options.vim.formatter.conform-nvim.presets.buf = {
    enable = mkFormatterPresetEnableOption {
      option = "buf";
      display = "Buf";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.buf = {
      command = getExe pkgs.buf;
    };
  };
}
