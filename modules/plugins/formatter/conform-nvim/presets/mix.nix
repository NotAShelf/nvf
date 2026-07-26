{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe';

  cfg = config.vim.formatter.conform-nvim.presets.mix;
in {
  options.vim.formatter.conform-nvim.presets.mix = {
    enable = mkFormatterPresetEnableOption {
      option = "mix";
      display = "`mix`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.mix = {
      command = getExe' pkgs.elixir "mix";
    };
  };
}
