{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.sqlfluff;
in {
  options.vim.diagnostics.presets.sqlfluff = {
    enable = mkDiagnosticsPresetEnableOption "sqlfluff" "SQLFluff";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.sqlfluff = {
      cmd = getExe pkgs.sqlfluff;
      args = ["lint" "--format=json"];
    };
  };
}
