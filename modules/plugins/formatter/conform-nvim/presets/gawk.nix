{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.formatter.conform-nvim.presets.gawk;
in {
  options.vim.formatter.conform-nvim.presets.gawk = {
    enable = mkFormatterPresetEnableOption {
      option = "gawk";
      display = "GNU AWK";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.gawk = {
      command = getExe pkgs.gawk;
      args = ["-f" "-" "-o-"];
    };
  };
}
