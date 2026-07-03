{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.csharpier;
in {
  options.vim.formatter.conform-nvim.presets.csharpier = {
    enable = mkFormatterPresetEnableOption {
      option = "csharpier";
      display = "CSharpier";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.csharpier = {
      command = "${pkgs.csharpier}/bin/csharpier";
      stdin = true;
      args = ["format"];
    };
  };
}
