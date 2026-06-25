{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;
  inherit (lib.meta) getExe';

  cfg = config.vim.debugger.nvim-dap.presets.jls;
  pkg = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.jls;
in {
  options.vim.debugger.nvim-dap.presets.jls = {
    enable = mkEnableOption ''
      adapter configuration for JLS.
      Use {option}`vim.debugger.nvim-dap.adapters.jls` for customization.

      A configuration is also needed for your filetype in
      {option}`vim.debugger.nvim-dap.configurations`
    '';
  };

  config.vim.debugger.nvim-dap.adapters = mkIf cfg.enable {
    jls = {
      type = "executable";
      command = getExe' pkg "jls-dap";
    };
  };
}
