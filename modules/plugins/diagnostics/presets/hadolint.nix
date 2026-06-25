{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.hadolint;
in {
  options.vim.diagnostics.presets.hadolint = {
    enable = mkDiagnosticsPresetEnableOption "hadolint" "Hadolint";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.hadolint.cmd = getExe pkgs.hadolint;
  };
}
