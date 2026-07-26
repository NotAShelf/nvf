{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.formatter.conform-nvim.presets.rubocop;
in {
  options.vim.formatter.conform-nvim.presets.rubocop = {
    enable = mkFormatterPresetEnableOption {
      option = "rubocop";
      display = "RuboCop";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.rubocop = {
      command = getExe pkgs.rubocop;
    };
  };
}
