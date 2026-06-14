{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.alejandra;
in {
  options.vim.formatter.conform-nvim.presets.alejandra = {
    enable = mkFormatterPresetEnableOption {
      option = "alejandra";
      display = "Alejandra";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.alejandra = {
      command = "${pkgs.alejandra}/bin/alejandra";
    };
  };
}
