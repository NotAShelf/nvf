{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.rubocop;
in {
  options.vim.diagnostics.presets.rubocop = {
    enable = mkDiagnosticsPresetEnableOption "rubocop" "RuboCop";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.rubocop.cmd = getExe pkgs.rubyPackages.rubocop;
  };
}
