{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.luacheck;
in {
  options.vim.diagnostics.presets.luacheck = {
    enable = mkDiagnosticsPresetEnableOption "luacheck" "Luacheck";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.luacheck.cmd = getExe pkgs.luajitPackages.luacheck;
  };
}
