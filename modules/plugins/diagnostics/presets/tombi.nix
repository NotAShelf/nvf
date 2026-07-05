{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.tombi;
in {
  options.vim.diagnostics.presets.tombi = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "tombi";
      display = "Tombi";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.tombi = {
      cmd = "${pkgs.tombi}/bin/tombi";
      args = ["lint"];
    };
  };
}
