{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.markdownlint-cli2;
in {
  options.vim.diagnostics.presets.markdownlint-cli2 = {
    enable = mkDiagnosticsPresetEnableOption "markdownlint-cli2" "Markdownlint CLI 2";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.markdownlint-cli2.cmd = getExe pkgs.markdownlint-cli2;
  };
}
