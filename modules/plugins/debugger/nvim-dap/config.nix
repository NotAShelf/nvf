{
  options,
  config,
  lib,
  ...
}: let
  inherit (lib.strings) optionalString;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.nvim.binds) mkKeymap;
  inherit (lib.nvim.dag) entryAnywhere entryAfter;

  cfg = config.vim.debugger.nvim-dap;
  inherit (options.vim.debugger.nvim-dap) mappings;
in {
  config = mkMerge [
    (mkIf cfg.enable {
      vim = {
        startPlugins = ["nvim-dap"];

        pluginRC =
          {
            # TODO customizable keymaps
            nvim-dap = entryAnywhere ''
              local dap = require("dap")
              vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "ErrorMsg", linehl = "", numhl = "" })
            '';
          }
          // mapAttrs (_: v: (entryAfter ["nvim-dap"] v)) cfg.sources;

        keymaps = [
          (mkKeymap "n" cfg.mappings.continue "require('dap').continue" {desc = mappings.continue.description;})
          (mkKeymap "n" cfg.mappings.restart "require('dap').restart" {desc = mappings.restart.description;})
          (mkKeymap "n" cfg.mappings.terminate "require('dap').terminate" {desc = mappings.terminate.description;})
          (mkKeymap "n" cfg.mappings.runLast "require('dap').run_last" {desc = mappings.runLast.description;})

          (mkKeymap "n" cfg.mappings.toggleRepl "require('dap').repl.toggle" {desc = mappings.toggleRepl.description;})
          (mkKeymap "n" cfg.mappings.hover "require('dap.ui.widgets').hover" {desc = mappings.hover.description;})
          (mkKeymap "n" cfg.mappings.toggleBreakpoint "require('dap').toggle_breakpoint" {desc = mappings.toggleBreakpoint.description;})

          (mkKeymap "n" cfg.mappings.runToCursor "require('dap').run_to_cursor" {desc = mappings.runToCursor.description;})
          (mkKeymap "n" cfg.mappings.stepInto "require('dap').step_into" {desc = mappings.stepInto.description;})
          (mkKeymap "n" cfg.mappings.stepOut "require('dap').step_out" {desc = mappings.stepOut.description;})
          (mkKeymap "n" cfg.mappings.stepOver "require('dap').step_over" {desc = mappings.stepOver.description;})
          (mkKeymap "n" cfg.mappings.stepBack "require('dap').step_back" {desc = mappings.stepBack.description;})

          (mkKeymap "n" cfg.mappings.goUp "require('dap').up" {desc = mappings.goUp.description;})
          (mkKeymap "n" cfg.mappings.goDown "require('dap').down" {desc = mappings.goDown.description;})
        ];
      };
    })
    (mkIf (cfg.enable && cfg.ui.enable) {
      vim = {
        startPlugins = ["nvim-nio"];

        lazy.plugins.nvim-dap-ui = {
          package = "nvim-dap-ui";
          setupModule = "dapui";
          inherit (cfg.ui) setupOpts;

          keys = [
            (mkKeymap "n" cfg.mappings.toggleDapUI "function() require('dapui').toggle() end" {desc = mappings.toggleDapUI.description;})
          ];
        };

        pluginRC.nvim-dap-ui = entryAfter ["nvim-dap"] (
          optionalString cfg.ui.autoStart ''
            dap.listeners.after.event_initialized["dapui_config"] = function()
              require("dapui").open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
              require("dapui").close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
              require("dapui").close()
            end
          ''
        );
      };
    })
  ];
}
