{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.ktlint;
in {
  options.vim.diagnostics.presets.ktlint = {
    enable = mkDiagnosticsPresetEnableOption "ktlint" "ktlint";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.ktlint.cmd = getExe pkgs.ktlint;
  };
}
