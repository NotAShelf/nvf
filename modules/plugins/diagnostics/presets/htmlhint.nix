{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.htmlhint;
in {
  options.vim.diagnostics.presets.htmlhint = {
    enable = mkDiagnosticsPresetEnableOption "htmlhint" "HTMLHint";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.htmlhint.cmd = getExe pkgs.htmlhint;
  };
}
