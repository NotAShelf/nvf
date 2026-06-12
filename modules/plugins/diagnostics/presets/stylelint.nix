{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.stylelint;
in {
  options.vim.diagnostics.presets.stylelint = {
    enable = mkDiagnosticsPresetEnableOption "stylelint" "Stylelint";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.stylelint.cmd = getExe pkgs.stylelint;
  };
}
