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

      vim.luaConfigRC =
        {
          # TODO customizable keymaps
          nvim-dap = nvim.dag.entryAnywhere ''
            local dap = require("dap")
            local opts = { noremap = true, silent = true }

            vim.keymap.set("n", "<leader>d.", "<cmd>lua require'dap'.run_last()<cr>", opts)
            vim.keymap.set("n", "<leader>dR", "<cmd>lua require'dap'.restart()<cr>", opts)
            vim.keymap.set("n", "<leader>dq", "<cmd>lua require'dap'.terminate()<cr>", opts)
            vim.keymap.set("n", "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", opts)
            vim.keymap.set("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", opts)
            vim.keymap.set("n", "<leader>dl", "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>", opts)
            vim.keymap.set("n", "<leader>dgb", "<cmd>lua require'dap'.continue()<cr>", opts)
            vim.keymap.set("n", "<leader>dgc", "<cmd>lua require'dap'.run_to_cursor()<cr>", opts)
            vim.keymap.set("n", "<leader>dgi", "<cmd>lua require'dap'.step_into()<cr>", opts)
            vim.keymap.set("n", "<leader>dgo", "<cmd>lua require'dap'.step_out()<cr>", opts)
            vim.keymap.set("n", "<leader>dgI", "<cmd>lua require'dap'.down()<cr>", opts)
            vim.keymap.set("n", "<leader>dgO", "<cmd>lua require'dap'.up()<cr>", opts)
            vim.keymap.set("n", "<leader>dgj", "<cmd>lua require'dap'.step_over()<cr>", opts)
            vim.keymap.set("n", "<leader>dgk", "<cmd>lua require'dap'.step_back()<cr>", opts)
            vim.keymap.set("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", opts)
            vim.keymap.set("n", "<leader>dh", "<cmd>lua require'dap.ui.widgets'.hover()<cr>", opts)

          '';
        }
        // mapAttrs (_: v: (nvim.dag.entryAfter ["nvim-dap"] v)) cfg.sources;
    })
    (mkIf (cfg.enable && cfg.ui.enable) {
      vim.startPlugins = ["nvim-dap-ui"];

      vim.luaConfigRC.nvim-dap-ui = nvim.dag.entryAfter ["nvim-dap"] (''
          local dapui = require("dapui")
          require("dapui").setup()
          vim.keymap.set("n", "<leader>du", "<cmd>lua require'dapui'.toggle()<cr>", opts)
          vim.keymap.set({ "n", "v" }, "<leader>dd", "<cmd>lua require'dapui'.eval()<cr>", opts)
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
