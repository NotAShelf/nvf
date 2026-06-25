{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.statix;
in {
  options.vim.diagnostics.presets.statix = {
    enable = mkDiagnosticsPresetEnableOption "statix" "Statix";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.statix.cmd = getExe pkgs.statix;
  };
}
