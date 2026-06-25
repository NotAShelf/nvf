{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.debugger.nvim-dap.presets.lldb;
in {
  options.vim.debugger.nvim-dap.presets.lldb = {
    enable = mkEnableOption ''
      adapter configuration for LLDB using `lldb-dap`.
      Use {option}`vim.debugger.nvim-dap.adapters.lldb` for customization.

      A configuration is also needed for your filetype in
      {option}`vim.debugger.nvim-dap.configurations`
    '';
  };

  config.vim.debugger.nvim-dap.adapters = mkIf cfg.enable {
    lldb = {
      type = "executable";
      command = "${pkgs.lldb}/bin/lldb-dap";
    };
  };
}
