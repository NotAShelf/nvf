{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.floskell;
in {
  options.vim.formatter.conform-nvim.presets.floskell = {
    enable = mkFormatterPresetEnableOption {
      option = "floskell";
      display = "Floskell";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.floskell = {
      command = "${pkgs.haskellPackages.floskell}/bin/floskell";
      stdin = true;
    };
  };
}
