{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.stylelint;
in {
  options.vim.diagnostics.presets.stylelint = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "stylelint";
      display = "Stylelint";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.stylelint.cmd = "${pkgs.stylelint}/bin/stylelint";
  };
}
