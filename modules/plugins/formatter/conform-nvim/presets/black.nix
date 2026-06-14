{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.black;
in {
  options.vim.formatter.conform-nvim.presets.black = {
    enable = mkFormatterPresetEnableOption {
      option = "black";
      display = "`black`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.black = {
      command = "${pkgs.black}/bin/black";
      stdin = true;
    };
  };
}
