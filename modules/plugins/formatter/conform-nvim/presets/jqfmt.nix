{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.jqfmt;
in {
  options.vim.formatter.conform-nvim.presets.jqfmt = {
    enable = mkFormatterPresetEnableOption {
      option = "jqfmt";
      display = "JQ FMT";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.jqfmt = {
      command = "${pkgs.jqfmt}/bin/jqfmt";
      args = [
        "-ob"
        "-ar"
        "-op=pipe"
      ];
      stdio = true;
    };
  };
}
