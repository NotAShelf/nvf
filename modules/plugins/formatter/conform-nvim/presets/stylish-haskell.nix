{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.formatter.conform-nvim.presets.stylish-haskell;
in {
  options.vim.formatter.conform-nvim.presets.stylish-haskell = {
    enable = mkFormatterPresetEnableOption {
      option = "stylish-haskell";
      display = "`stylish-haskell`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.stylish-haskell = {
      command = getExe pkgs.haskellPackages.stylish-haskell;
    };
  };
}
