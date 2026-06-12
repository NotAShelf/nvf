{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.dotenv-linter;
in {
  options.vim.diagnostics.presets.dotenv-linter = {
    enable = mkDiagnosticsPresetEnableOption "dotenv-linter" "Dotenv Linter";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.dotenv-linter.cmd = getExe pkgs.dotenv-linter;
  };
}
