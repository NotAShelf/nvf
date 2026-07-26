{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.diagnostics.presets;
in {
  options.vim.diagnostics.presets = {
    mago_lint.enable = mkDiagnosticsPresetEnableOption {
      option = "mago";
      display = "Mago";
      extra = "Only the linter. use `mago_analyze` for the full results.";
    };
    mago_analyze.enable = mkDiagnosticsPresetEnableOption {
      option = "mago";
      display = "Mago";
      extra = "Slower, but full analysis. use `mago_lint` for faster, but less precise results.";
    };
  };

  config.vim.diagnostics.nvim-lint.linters = {
    mago_lint = mkIf cfg.mago_lint.enable {
      cmd = getExe pkgs.mago;
    };
    mago_analyze = mkIf cfg.mago_analyze.enable {
      cmd = getExe pkgs.mago;
    };
  };
}
