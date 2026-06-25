{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.mypy;
in {
  options.vim.diagnostics.presets.mypy = {
    enable = mkDiagnosticsPresetEnableOption "mypy" "Mypy";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.mypy.cmd = getExe' pkgs.mypy "mypy";
  };
}
