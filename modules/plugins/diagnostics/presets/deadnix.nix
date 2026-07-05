{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.deadnix;
in {
  options.vim.diagnostics.presets.deadnix = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "deadnix";
      display = "Deadnix";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.deadnix.cmd = "${pkgs.deadnix}/bin/deadnix";
  };
}
