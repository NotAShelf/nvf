{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.format-r;
in {
  options.vim.formatter.conform-nvim.presets.format-r = {
    enable = mkFormatterPresetEnableOption {
      option = "format-r";
      display = "formatR";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.format-r = {
      command = "${pkgs.rWrapper.override {packages = [pkgs.rPackages.formatR];}}/bin/R";
      stdin = true;
      args = [
        "--slave"
        "--no-restore"
        "--no-save"
        "-s"
        "-e"
        ''formatR::tidy_source(source="stdin")''
      ];

      # TODO (@hihi): range_args seem to be possible
      # https://github.com/nvimtools/none-ls.nvim/blob/main/lua/null-ls/builtins/formatting/format_r.lua
    };
  };
}
