{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.cpplint;
in {
  options.vim.diagnostics.presets.cpplint = {
    enable = mkDiagnosticsPresetEnableOption "cpplint" "cpplint";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.cpplint.cmd = getExe pkgs.cpplint;
  };
}
