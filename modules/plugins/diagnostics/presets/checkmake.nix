{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.checkmake;
in {
  options.vim.diagnostics.presets.checkmake = {
    enable = mkDiagnosticsPresetEnableOption "checkmake" "Checkmake";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.checkmake.cmd = getExe pkgs.checkmake;
  };
}
