{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.rubocop;
in {
  options.vim.diagnostics.presets.rubocop = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "rubocop";
      display = "RuboCop";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.rubocop.cmd = "${pkgs.rubocop}/bin/rubocop";
  };
}
