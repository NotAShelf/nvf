{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.mbake;
in {
  options.vim.formatter.conform-nvim.presets.mbake = {
    enable = mkFormatterPresetEnableOption {
      option = "mbake";
      display = "🍞 mbake";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.mbake = {
      command = "${pkgs.mbake}/bin/mbake";
      args = [
        "format"
        "--stdin"
      ];
    };
  };
}
