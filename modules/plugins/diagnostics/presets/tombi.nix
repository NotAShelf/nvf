{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.tombi;
in {
  options.vim.diagnostics.presets.tombi = {
    enable = mkDiagnosticsPresetEnableOption "tombi" "Tombi";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.tombi = {
      cmd = getExe pkgs.tombi;
      args = ["lint"];
    };
  };
}
