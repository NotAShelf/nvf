{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDapPresetEnableOption;

  cfg = config.vim.debugger.nvim-dap.presets.lldb;
in {
  options.vim.debugger.nvim-dap.presets.lldb = {
    enable = mkDapPresetEnableOption {
      option = "lldb";
      display = "LLDB";
      extra = "Uses `lldb-dap` under the hood.";
    };
  };

  config.vim.debugger.nvim-dap.adapters = mkIf cfg.enable {
    lldb = {
      type = "executable";
      command = "${pkgs.lldb}/bin/lldb-dap";
    };
  };
}
