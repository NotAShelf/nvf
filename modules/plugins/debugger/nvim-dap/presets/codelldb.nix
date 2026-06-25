{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.vim.debugger.nvim-dap.presets.codelldb;
  codelldb = pkgs.vscode-extensions.vadimcn.vscode-lldb.adapter;
in {
  options.vim.debugger.nvim-dap.presets.codelldb = {
    enable = mkEnableOption ''
      adapter configuration for CodeLLDB using the vadimcn.vscode-lldb extension.
      Use {option}`vim.debugger.nvim-dap.adapters.codelldb` for customization.

      A configuration is also needed for your filetype in
      {option}`vim.debugger.nvim-dap.configurations`
    '';
  };

  # Taken from rustaceanvim internal setup. Unsure if all of these are required.
  config.vim.debugger.nvim-dap.adapters = mkIf cfg.enable {
    codelldb = {
      type = "server";
      host = "127.0.0.1";
      port = "\${port}";
      executable = {
        command = "${codelldb}/bin/codelldb";
        args = ["--liblldb" "${codelldb}/share/lldb/lib/liblldb.so" "--port" "\${port}"];
      };
    };
  };
}
