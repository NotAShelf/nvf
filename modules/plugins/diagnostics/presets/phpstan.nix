{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.diagnostics.presets.phpstan;
in {
  options.vim.diagnostics.presets.phpstan = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "phpstan";
      display = "PHPStan";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.phpstan.cmd = getExe pkgs.phpstan;
  };
}
