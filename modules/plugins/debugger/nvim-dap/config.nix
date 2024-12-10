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
  opt = {
    silent = true;
    lua = true;
  };
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
          (mkKeymap "n" cfg.mappings.continue "require('dap').continue" (opt // {desc = mappings.continue.description;}))
          (mkKeymap "n" cfg.mappings.restart "require('dap').restart" (opt // {desc = mappings.restart.description;}))
          (mkKeymap "n" cfg.mappings.terminate "require('dap').terminate" (opt // {desc = mappings.terminate.description;}))
          (mkKeymap "n" cfg.mappings.runLast "require('dap').run_last" (opt // {desc = mappings.runLast.description;}))

          (mkKeymap "n" cfg.mappings.toggleRepl "require('dap').repl.toggle" (opt // {desc = mappings.toggleRepl.description;}))
          (mkKeymap "n" cfg.mappings.hover "require('dap.ui.widgets').hover" (opt // {desc = mappings.hover.description;}))
          (mkKeymap "n" cfg.mappings.toggleBreakpoint "require('dap').toggle_breakpoint" (opt // {desc = mappings.toggleBreakpoint.description;}))

          (mkKeymap "n" cfg.mappings.runToCursor "require('dap').run_to_cursor" (opt // {desc = mappings.runToCursor.description;}))
          (mkKeymap "n" cfg.mappings.stepInto "require('dap').step_into" (opt // {desc = mappings.stepInto.description;}))
          (mkKeymap "n" cfg.mappings.stepOut "require('dap').step_out" (opt // {desc = mappings.stepOut.description;}))
          (mkKeymap "n" cfg.mappings.stepOver "require('dap').step_over" (opt // {desc = mappings.stepOver.description;}))
          (mkKeymap "n" cfg.mappings.stepBack "require('dap').step_back" (opt // {desc = mappings.stepBack.description;}))

          (mkKeymap "n" cfg.mappings.goUp "require('dap').up" (opt // {desc = mappings.goUp.description;}))
          (mkKeymap "n" cfg.mappings.goDown "require('dap').down" (opt // {desc = mappings.goDown.description;}))
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
            (mkKeymap "n" cfg.mappings.toggleDapUI "function() require('dapui').toggle() end" (opt // {desc = mappings.toggleDapUI.description;}))
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
