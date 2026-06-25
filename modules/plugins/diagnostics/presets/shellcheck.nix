{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.shellcheck;
in {
  options.vim.diagnostics.presets.shellcheck = {
    enable = mkDiagnosticsPresetEnableOption "shellcheck" "Shellcheck";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.shellcheck.cmd = getExe pkgs.shellcheck;
  };
}
