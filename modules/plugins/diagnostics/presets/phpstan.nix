{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.phpstan;
in {
  options.vim.diagnostics.presets.phpstan = {
    enable = mkDiagnosticsPresetEnableOption "phpstan" "PHPStan";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.phpstan.cmd = getExe pkgs.phpstan;
  };
}
