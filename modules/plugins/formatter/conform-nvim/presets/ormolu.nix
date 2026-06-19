{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.ormolu;
in {
  options.vim.formatter.conform-nvim.presets.ormolu = {
    enable = mkFormatterPresetEnableOption {
      option = "ormolu";
      display = "Ormolu";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.ormolu = {
      command = "${pkgs.haskellPackages.ormolu}/bin/ormolu";
    };
  };
}
