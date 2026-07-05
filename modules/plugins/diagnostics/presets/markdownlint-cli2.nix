{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.markdownlint-cli2;
in {
  options.vim.diagnostics.presets.markdownlint-cli2 = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "markdownlint-cli2";
      display = "Markdownlint CLI 2";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.markdownlint-cli2.cmd = "${pkgs.markdownlint-cli2}/bin/markdownlint-cli2";
  };
}
