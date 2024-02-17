{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types mkMappingOption;
in {
  options.vim.debugger.nvim-dap = {
    enable = mkEnableOption "debugging via nvim-dap";

    ui = {
      enable = mkEnableOption "UI extension for nvim-dap";
      autoStart = mkOption {
        type = types.bool;
        default = true;
        description = "Automatically Opens and Closes DAP-UI upon starting/closing a debugging session";
      };
    };

    sources = mkOption {
      default = {};
      description = "List of debuggers to install";
      type = with types; attrsOf str;
    };

    mappings = {
      continue = mkMappingOption "Contiue" "<leader>dc";
      restart = mkMappingOption "Restart" "<leader>dR";
      terminate = mkMappingOption "Terminate" "<leader>dq";
      runLast = mkMappingOption "Re-run Last Debug Session" "<leader>d.";

      toggleRepl = mkMappingOption "Toggle Repl" "<leader>dr";
      hover = mkMappingOption "Hover" "<leader>dh";
      toggleBreakpoint = mkMappingOption "Toggle breakpoint" "<leader>db";

      runToCursor = mkMappingOption "Continue to the current cursor" "<leader>dgc";
      stepInto = mkMappingOption "Step into function" "<leader>dgi";
      stepOut = mkMappingOption "Step out of function" "<leader>dgo";
      stepOver = mkMappingOption "Next step" "<leader>dgj";
      stepBack = mkMappingOption "Step back" "<leader>dgk";

      goUp = mkMappingOption "Go up stacktrace" "<leader>dvo";
      goDown = mkMappingOption "Go down stacktrace" "<leader>dvi";

      toggleDapUI = mkMappingOption "Toggle DAP-UI" "<leader>du";
    };
  };
}
