{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.dotenv-linter;
in {
  options.vim.diagnostics.presets.dotenv-linter = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "dotenv-linter";
      display = "Dotenv Linter";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.dotenv-linter.cmd = "${pkgs.dotenv-linter}/bin/dotenv-linter";
  };
}
