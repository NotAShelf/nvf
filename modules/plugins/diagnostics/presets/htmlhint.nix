{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.diagnostics.presets.htmlhint;
in {
  options.vim.diagnostics.presets.htmlhint = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "htmlhint";
      display = "HTMLHint";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.htmlhint.cmd = getExe pkgs.htmlhint;
  };
}
