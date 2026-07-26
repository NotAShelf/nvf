{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.diagnostics.presets.checkmake;
in {
  options.vim.diagnostics.presets.checkmake = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "checkmake";
      display = "Checkmake";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.checkmake.cmd = getExe pkgs.checkmake;
  };
}
