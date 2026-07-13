{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDapPresetEnableOption;

  cfg = config.vim.debugger.nvim-dap.presets.codelldb;
  codelldb = pkgs.vscode-extensions.vadimcn.vscode-lldb.adapter;
in {
  options.vim.debugger.nvim-dap.presets.codelldb = {
    enable = mkDapPresetEnableOption {
      option = "codelldb";
      display = "CodeLLDB";
      extra = "Uses the vadimcn.vscode-lldb extension under the hood.";
    };
  };

  config.vim.debugger.nvim-dap.adapters = mkIf cfg.enable {
    codelldb = {
      type = "server";
      port = "\${port}";
      executable = {
        command = "${codelldb}/bin/codelldb";
        args = ["--liblldb" "${codelldb}/share/lldb/lib/liblldb.so" "--port" "\${port}"];
      };
    };
  };
}
