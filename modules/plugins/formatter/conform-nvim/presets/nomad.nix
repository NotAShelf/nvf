{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.formatter.conform-nvim.presets.nomad;
in {
  options.vim.formatter.conform-nvim.presets.nomad = {
    enable = mkFormatterPresetEnableOption {
      option = "nomad";
      display = "Nomad";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.nomad = {
      command = getExe pkgs.nomad;
      args = ["fmt" "$FILENAME"];
      stdin = false;
    };
  };
}
