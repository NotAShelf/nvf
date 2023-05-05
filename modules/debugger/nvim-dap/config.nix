{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.debugger.nvim-dap;
in {
  config = mkMerge [
    (mkIf cfg.enable {
      vim.startPlugins = ["nvim-dap"];

      vim.luaConfigRC.nvim-dap =
        nvim.dag.entryAnywhere ''
        '';
    })
    (mkIf (cfg.enable && cfg.ui.enable) {
      vim.startPlugins = ["nvim-dap-ui"];

      vim.luaConfigRC.nvim-dap-ui = nvim.dag.entryAfter ["nvim-dap"] (''
          local dapui = require("dapui")
          require("dapui").setup()
        ''
        + optionalString cfg.ui.autoStart ''
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
          end
        '');
    })
  ];
}
