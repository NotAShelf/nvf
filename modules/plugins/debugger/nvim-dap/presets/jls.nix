{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.meta) getExe';
  inherit (lib.nvim.types) mkDapPresetEnableOption;

  cfg = config.vim.debugger.nvim-dap.presets.jls;
  pkg = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.jls;
in {
  options.vim.debugger.nvim-dap.presets.jls = {
    enable = mkDapPresetEnableOption {
      option = "jls";
      display = "JLS";
    };
  };

  config.vim.debugger.nvim-dap.adapters = mkIf cfg.enable {
    jls = {
      type = "executable";
      command = getExe' pkg "jls-dap";
    };
  };
}
