{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.diagnostics.presets.taplo;
in {
  options.vim.diagnostics.presets.taplo = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "taplo";
      display = "Taplo";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.taplo = {
      cmd = getExe pkgs.taplo;
      args = ["lint"];
    };
  };
}
