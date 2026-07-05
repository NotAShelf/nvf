{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.shellcheck;
in {
  options.vim.diagnostics.presets.shellcheck = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "shellcheck";
      display = "Shellcheck";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.shellcheck.cmd = "${pkgs.shellcheck}/bin/shellcheck";
  };
}
