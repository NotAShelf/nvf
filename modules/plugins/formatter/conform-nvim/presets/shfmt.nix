{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.shfmt;
in {
  options.vim.formatter.conform-nvim.presets.shfmt = {
    enable = mkFormatterPresetEnableOption {
      option = "shfmt";
      display = "`shfmt`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.shfmt = {
      command = "${pkgs.shfmt}/bin/shfmt";
    };
  };
}
