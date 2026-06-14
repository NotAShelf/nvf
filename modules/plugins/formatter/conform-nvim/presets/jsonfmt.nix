{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.jsonfmt;
in {
  options.vim.formatter.conform-nvim.presets.jsonfmt = {
    enable = mkFormatterPresetEnableOption {
      option = "jsonfmt";
      display = "`jsonfmt`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.jsonfmt = {
      command = "${pkgs.jsonfmt}/bin/jsonfmt";
      args = ["--write" "-"];
    };
  };
}
