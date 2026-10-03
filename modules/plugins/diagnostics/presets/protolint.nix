{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.diagnostics.presets.protolint;
in {
  options.vim.diagnostics.presets.protolint = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "protolint";
      display = "`protolint`";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.protolint = {
      cmd = getExe pkgs.protolint;
    };
  };
}
