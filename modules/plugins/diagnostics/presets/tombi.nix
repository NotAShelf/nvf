{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.diagnostics.presets.tombi;
in {
  options.vim.diagnostics.presets.tombi = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "tombi";
      display = "Tombi";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.tombi = {
      cmd = getExe pkgs.tombi;
      args = ["lint"];
    };
  };
}
