{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.formatter.conform-nvim.presets.sqlfluff;
in {
  options.vim.formatter.conform-nvim.presets.sqlfluff = {
    enable = mkFormatterPresetEnableOption {
      option = "sqlfluff";
      display = "SQLFluff";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.sqlfluff = {
      command = getExe pkgs.sqlfluff;
    };
  };
}
