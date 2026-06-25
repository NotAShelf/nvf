{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.eslint_d;
in {
  options.vim.diagnostics.presets.eslint_d = {
    enable = mkDiagnosticsPresetEnableOption "eslint_d" "Eslint Daemon";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.eslint_d = {
      cmd = getExe pkgs.eslint_d;
      required_files = [
        "eslint.config.js"
        "eslint.config.mjs"
        ".eslintrc"
        ".eslintrc.json"
        ".eslintrc.js"
        ".eslintrc.yml"
      ];
    };
  };
}
