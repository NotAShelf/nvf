{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.sqruff;
in {
  options.vim.formatter.conform-nvim.presets.sqruff = {
    enable = mkFormatterPresetEnableOption {
      option = "sqruff";
      display = "Sqruff";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.sqruff = {
      command = "${pkgs.sqruff}/bin/sqruff";
    };
  };
}
