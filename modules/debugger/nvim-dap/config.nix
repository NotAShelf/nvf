{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.debugger.nvim-dap;
in {
  config = mkIf cfg.enable {
    vim.startPlugins =
      [
        "nvim-dap"
      ]
      ++ optionals cfg.ui.enable [
        "nvim-dap-ui"
      ];

    vim.luaConfigRC.nvim-dap-ui = nvim.dag.entryAnywhere ''
      require("dapui").setup()
    '';
  };
}
