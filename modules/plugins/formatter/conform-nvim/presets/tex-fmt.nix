{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.formatter.conform-nvim.presets.tex-fmt;
in {
  options.vim.formatter.conform-nvim.presets.tex-fmt = {
    enable = mkFormatterPresetEnableOption {
      option = "tex-fmt";
      display = "TEX-FMT";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.tex-fmt = {
      command = getExe pkgs.tex-fmt;
    };
  };
}
