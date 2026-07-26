{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.diagnostics.presets.dotenv-linter;
in {
  options.vim.diagnostics.presets.dotenv-linter = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "dotenv-linter";
      display = "Dotenv Linter";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.dotenv-linter.cmd = getExe pkgs.dotenv-linter;
  };
}
