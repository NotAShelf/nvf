{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.diagnostics.presets.djlint;
in {
  options.vim.diagnostics.presets.djlint = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "djlint";
      display = "djLint";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.djlint.cmd = getExe pkgs.djlint;
  };
}
