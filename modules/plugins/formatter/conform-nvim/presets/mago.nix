{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets;
in {
  options.vim.formatter.conform-nvim.presets = {
    mago = {
      enable = mkFormatterPresetEnableOption {
        option = "mago";
        display = "Mago";
      };
    };
    mago-fix = {
      enable = mkFormatterPresetEnableOption {
        option = "mago-fix";
        display = "Mago";
        extra = "This variant runs automatic linter fixes.";
      };
    };
  };

  config = {
    vim.formatter.conform-nvim.setupOpts.formatters = {
      mago = mkIf cfg.mago.enable {
        command = "${pkgs.mago}/bin/mago";
        stdin = true;
        args = [
          "--colors=never"
          "format"
          "--stdin-input"
        ];
      };
      mago-fix = mkIf cfg.mago-fix.enable {
        command = "${pkgs.mago}/bin/mago";
        stdin = true;
        args = [
          "--colors=never"
          "lint"
          "--stdin-input"
          "--fix"
          "--format-after-fix"
        ];
      };
    };
  };
}
