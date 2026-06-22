{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.deadnix;
in {
  options.vim.diagnostics.presets.deadnix = {
    enable = mkDiagnosticsPresetEnableOption "deadnix" "Deadnix";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.deadnix.cmd = getExe pkgs.deadnix;
  };
}
