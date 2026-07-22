{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.formatter.conform-nvim.presets.rustfmt;
in {
  options.vim.formatter.conform-nvim.presets.rustfmt = {
    enable = mkFormatterPresetEnableOption {
      option = "rustfmt";
      display = "`rustfmt`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.rustfmt = {
      command = getExe pkgs.rustfmt;
      options.default_edition = "2024";
    };
  };
}
