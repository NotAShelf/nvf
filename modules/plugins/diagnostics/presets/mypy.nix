{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.mypy;
in {
  options.vim.diagnostics.presets.mypy = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "mypy";
      display = "Mypy";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.mypy.cmd = "${pkgs.mypy}/bin/mypy";
  };
}
