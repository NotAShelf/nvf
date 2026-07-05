{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.biomejs;
in {
  options.vim.diagnostics.presets.biomejs = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "biomejs";
      display = "Biome";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.biomejs.cmd = "${pkgs.biome}/bin/biome";
  };
}
