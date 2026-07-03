{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.clangtidy;
in {
  options.vim.diagnostics.presets.clangtidy = {
    enable = mkDiagnosticsPresetEnableOption "clangtidy" "Clang-Tidy";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.clangtidy.cmd = getExe pkgs.clangtidy;
  };
}
