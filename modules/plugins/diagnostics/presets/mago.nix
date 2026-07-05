{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets;
in {
  options.vim.diagnostics.presets = {
    mago_lint = {
      enable = mkDiagnosticsPresetEnableOption "mago" "Mago lint";
    };

    mago_analyze = {
      enable = mkDiagnosticsPresetEnableOption "mago" "Mago analyzer";
    };
  };

  config.vim.diagnostics.nvim-lint.linters = {
    mago_lint = mkIf cfg.mago_lint.enable {
      cmd = "${pkgs.mago}/bin/mago";
    };
    mago_analyze = mkIf cfg.mago_analyze.enable {
      cmd = "${pkgs.mago}/bin/mago";
    };
  };
}
