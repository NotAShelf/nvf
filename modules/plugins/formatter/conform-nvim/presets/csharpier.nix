{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe;

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
      command = getExe pkgs.csharpier;
      stdin = true;
      args = ["format"];
    };
  };
}
