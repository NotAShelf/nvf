{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.formatter.conform-nvim.presets.superhtml;
in {
  options.vim.formatter.conform-nvim.presets.superhtml = {
    enable = mkFormatterPresetEnableOption {
      option = "superhtml";
      display = "SuperHTML";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.superhtml = {
      command = getExe pkgs.superhtml;
      args = ["fmt" "--stdin"];
    };
  };
}
