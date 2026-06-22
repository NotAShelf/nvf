{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.taplo;
in {
  options.vim.diagnostics.presets.taplo = {
    enable = mkDiagnosticsPresetEnableOption "taplo" "Taplo";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.taplo = {
      cmd = getExe pkgs.taplo;
      args = ["lint"];
    };
  };
}
