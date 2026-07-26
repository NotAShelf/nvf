{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.diagnostics.presets.deadnix;
in {
  options.vim.diagnostics.presets.deadnix = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "deadnix";
      display = "Deadnix";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.deadnix.cmd = getExe pkgs.deadnix;
  };
}
