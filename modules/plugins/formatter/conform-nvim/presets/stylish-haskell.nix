{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

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
      command = "${pkgs.haskellPackages.stylish-haskell}/bin/stylish-haskell";
    };
  };
}
