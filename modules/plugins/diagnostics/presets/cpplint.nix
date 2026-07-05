{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.cpplint;
in {
  options.vim.diagnostics.presets.cpplint = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "cpplint";
      display = "Cpplint";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.cpplint.cmd = "${pkgs.cpplint}/bin/cpplint";
  };
}
