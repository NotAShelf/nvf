{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.diagnostics.presets.sqlfluff;
in {
  options.vim.diagnostics.presets.sqlfluff = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "sqlfluff";
      display = "SQLFluff";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.sqlfluff = {
      cmd = getExe pkgs.sqlfluff;
      args = ["lint" "--format=json"];
    };
  };
}
