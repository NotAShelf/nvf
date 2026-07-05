{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.phpstan;
in {
  options.vim.diagnostics.presets.phpstan = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "phpstan";
      display = "PHPStan";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.phpstan.cmd = "${pkgs.phpstan}/bin/phpstan";
  };
}
