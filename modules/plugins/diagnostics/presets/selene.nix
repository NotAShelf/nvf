{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.selene;
in {
  options.vim.diagnostics.presets.selene = {
    enable = mkDiagnosticsPresetEnableOption "selene" "Selene";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.selene.cmd = getExe pkgs.selene;
  };
}
