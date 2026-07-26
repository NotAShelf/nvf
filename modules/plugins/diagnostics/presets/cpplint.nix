{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.diagnostics.presets.cpplint;
in {
  options.vim.diagnostics.presets.cpplint = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "cpplint";
      display = "Cpplint";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.cpplint.cmd = getExe pkgs.cpplint;
  };
}
