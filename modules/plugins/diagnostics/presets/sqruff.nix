{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.diagnostics.presets.sqruff;
in {
  options.vim.diagnostics.presets.sqruff = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "sqruff";
      display = "Sqruff";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.sqruff = {
      cmd = getExe pkgs.sqruff;
      args = ["lint" "--format=json" "-"];
    };
  };
}
