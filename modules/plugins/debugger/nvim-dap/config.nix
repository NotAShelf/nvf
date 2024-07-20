{
  config,
  lib,
  ...
}: let
  inherit (lib.strings) optionalString;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetLuaBinding;
  inherit (lib.nvim.dag) entryAnywhere entryAfter;

  cfg = config.vim.debugger.nvim-dap;
  self = import ./nvim-dap.nix {inherit lib;};
  mappingDefinitions = self.options.vim.debugger.nvim-dap.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkMerge [
    (mkIf cfg.enable {
      vim.startPlugins = ["nvim-dap"];

      vim.pluginRC =
        {
          # TODO customizable keymaps
          nvim-dap = entryAnywhere ''
            local dap = require("dap")
            vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "ErrorMsg", linehl = "", numhl = "" })
          '';
        }
        // mapAttrs (_: v: (entryAfter ["nvim-dap"] v)) cfg.sources;

      vim.maps.normal = mkMerge [
        (mkSetLuaBinding mappings.continue "require('dap').continue")
        (mkSetLuaBinding mappings.restart "require('dap').restart")
        (mkSetLuaBinding mappings.terminate "require('dap').terminate")
        (mkSetLuaBinding mappings.runLast "require('dap').run_last")

        (mkSetLuaBinding mappings.toggleRepl "require('dap').repl.toggle")
        (mkSetLuaBinding mappings.hover "require('dap.ui.widgets').hover")
        (mkSetLuaBinding mappings.toggleBreakpoint "require('dap').toggle_breakpoint")

        (mkSetLuaBinding mappings.runToCursor "require('dap').run_to_cursor")
        (mkSetLuaBinding mappings.stepInto "require('dap').step_into")
        (mkSetLuaBinding mappings.stepOut "require('dap').step_out")
        (mkSetLuaBinding mappings.stepOver "require('dap').step_over")
        (mkSetLuaBinding mappings.stepBack "require('dap').step_back")

        (mkSetLuaBinding mappings.goUp "require('dap').up")
        (mkSetLuaBinding mappings.goDown "require('dap').down")
      ];
    })
    (mkIf (cfg.enable && cfg.ui.enable) {
      vim.startPlugins = ["nvim-dap-ui" "nvim-nio"];

      vim.pluginRC.nvim-dap-ui = entryAfter ["nvim-dap"] (''
          local dapui = require("dapui")
          dapui.setup()
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
      vim.maps.normal = mkSetLuaBinding mappings.toggleDapUI "require('dapui').toggle";
    })
  ];
}
