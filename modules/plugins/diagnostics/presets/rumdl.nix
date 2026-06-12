{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.rumdl;
in {
  options.vim.diagnostics.presets.rumdl = {
    enable = mkDiagnosticsPresetEnableOption "rumdl" "Rumdl";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.rumdl.cmd = getExe pkgs.rumdl;
  };
}
