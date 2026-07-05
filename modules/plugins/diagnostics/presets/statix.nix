{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.statix;
in {
  options.vim.diagnostics.presets.statix = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "statix";
      display = "Statix";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.statix.cmd = "${pkgs.statix}/bin/statix";
  };
}
