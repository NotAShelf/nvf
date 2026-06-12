{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.sqruff;
in {
  options.vim.diagnostics.presets.sqruff = {
    enable = mkDiagnosticsPresetEnableOption "sqruff" "Sqruff";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.sqruff = {
      cmd = getExe pkgs.sqruff;
      args = ["lint" "--format=json" "-"];
    };
  };
}
