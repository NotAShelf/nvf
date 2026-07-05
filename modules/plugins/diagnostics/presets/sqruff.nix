{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

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
      cmd = "${pkgs.sqruff}/bin/sqruff";
      args = ["lint" "--format=json" "-"];
    };
  };
}
