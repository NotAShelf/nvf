{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool attrsOf str;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.debugger.nvim-dap = {
    enable = mkEnableOption "debugging via nvim-dap";

    ui = {
      enable = mkEnableOption "UI extension for nvim-dap";

      setupOpts = mkPluginSetupOption "nvim-dap-ui" {};

      autoStart = mkOption {
        type = bool;
        default = true;
        description = "Automatically Opens and Closes DAP-UI upon starting/closing a debugging session";
      };
    };

    sources = mkOption {
      default = {};
      description = "List of debuggers to install";
      type = attrsOf str;
    };

    mappings = {
      continue = mkMappingOption config.vim.enableNvfKeymaps "Continue" "<leader>dc";
      restart = mkMappingOption config.vim.enableNvfKeymaps "Restart" "<leader>dR";
      terminate = mkMappingOption config.vim.enableNvfKeymaps "Terminate" "<leader>dq";
      runLast = mkMappingOption config.vim.enableNvfKeymaps "Re-run Last Debug Session" "<leader>d.";

      toggleRepl = mkMappingOption config.vim.enableNvfKeymaps "Toggle Repl" "<leader>dr";
      hover = mkMappingOption config.vim.enableNvfKeymaps "Hover" "<leader>dh";
      toggleBreakpoint = mkMappingOption config.vim.enableNvfKeymaps "Toggle breakpoint" "<leader>db";

      runToCursor = mkMappingOption config.vim.enableNvfKeymaps "Continue to the current cursor" "<leader>dgc";
      stepInto = mkMappingOption config.vim.enableNvfKeymaps "Step into function" "<leader>dgi";
      stepOut = mkMappingOption config.vim.enableNvfKeymaps "Step out of function" "<leader>dgo";
      stepOver = mkMappingOption config.vim.enableNvfKeymaps "Next step" "<leader>dgj";
      stepBack = mkMappingOption config.vim.enableNvfKeymaps "Step back" "<leader>dgk";

      goUp = mkMappingOption config.vim.enableNvfKeymaps "Go up stacktrace" "<leader>dvo";
      goDown = mkMappingOption config.vim.enableNvfKeymaps "Go down stacktrace" "<leader>dvi";

      toggleDapUI = mkMappingOption config.vim.enableNvfKeymaps "Toggle DAP-UI" "<leader>du";
    };
  };
}
