{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.diagnostics.presets.buf_lint;
in {
  options.vim.diagnostics.presets.buf_lint = {
    enable = mkDiagnosticsPresetEnableOption {
      option = "buf_lint";
      display = "Buf";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.buf_lint = {
      cmd = getExe pkgs.buf;
    };
  };
}
