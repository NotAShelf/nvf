{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.ktlint;
in {
  options.vim.diagnostics.presets.ktlint = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "ktlint";
      display = "ktlint";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.ktlint.cmd = "${pkgs.ktlint}/bin/ktlint";
  };
}
