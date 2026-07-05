{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.hadolint;
in {
  options.vim.diagnostics.presets.hadolint = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "hadolint";
      display = "Hadolint";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.hadolint.cmd = "${pkgs.hadolint}/bin/hadolint";
  };
}
