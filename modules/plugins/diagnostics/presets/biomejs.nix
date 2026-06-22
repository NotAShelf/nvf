{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.biomejs;
in {
  options.vim.diagnostics.presets.biomejs = {
    enable = mkDiagnosticsPresetEnableOption "biomejs" "Biome";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.biomejs.cmd = getExe pkgs.biome;
  };
}
