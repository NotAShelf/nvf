{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.djlint;
in {
  options.vim.diagnostics.presets.djlint = {
    enable = mkDiagnosticsPresetEnableOption "djlint" "djLint";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.djlint.cmd = getExe pkgs.djlint;
  };
}
