{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.diagnostics.presets.luacheck;
in {
  options.vim.diagnostics.presets.luacheck = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "luacheck";
      display = "Luacheck";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.luacheck.cmd = getExe pkgs.luajitPackages.luacheck;
  };
}
