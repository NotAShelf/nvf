{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool attrsOf str submodule anything either enum listOf nullOr int addCheck;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
  inherit (lib.nvim.lua) isLuaInline;
  inherit (config.vim.lib) mkMappingOption;

  adapterSubmodule = submodule {
    freeformType = attrsOf anything;
    options = {
      type = mkOption {
        type = enum ["executable" "server" "pipe"];
        description = "Type of adapter";
      };

      # executable

      command = mkOption {
        type = nullOr str;
        default = null;
        description = "Command to invoke";
      };

      args = mkOption {
        type = nullOr (listOf str);
        default = null;
        description = "Argument to the command";
      };

      # server

      host = mkOption {
        type = nullOr str;
        default = null;
        defaultText = "127.0.0.1"; # plugin default
        description = "Host to connect to";
      };

      port = mkOption {
        type = nullOr (either int (enum ["\${port}"]));
        default = null;
        description = ''
          Port to connect to. Use "''${port}" for a dynamically resolved free
          port. This is intended to be used with executable.args.
        '';
      };

      # pipe

      pipe = mkOption {
        type = nullOr str;
        default = null;
        description = ''
          Absolute path to the pipe file. Use \"''${pipe}\" for a dynamically
          generated temporary filename
        '';
      };
    };
  };

  adapterType = let
    submod = addCheck adapterSubmodule (x: !(isLuaInline x));
  in
    (either luaInline submod)
    // {
      getSubOptions = prefix: submod.getSubOptions prefix;
      inherit (submod) getSubModules;
      substSubModules = _: adapterType;
    };

  configurationType = submodule {
    freeformType = attrsOf anything;
    # These 3 options are required, everything else is passed to the debug
    # adapter
    options = {
      type = mkOption {
        type = str;
        description = "Which debug adapter to use";
      };

      request = mkOption {
        type = enum ["attach" "launch"];
        description = ''
          Indicates whether the debug adapter should launch a debuggee or attach
          to one that is already running.
        '';
      };

      name = mkOption {
        type = str;
        description = "A user-readable name for the configuration";
      };
    };
  };
in {
  options.vim.debugger.nvim-dap = {
    enable = mkEnableOption "debugging via nvim-dap";

    ui = {
      enable = mkEnableOption "UI extension for nvim-dap";

      setupOpts = mkPluginSetupOption "nvim-dap-ui" {};

      autoStart = mkOption {
        type = bool;
        default = true;
        description = ''
          Automatically Opens and Closes DAP-UI upon starting/closing a
          debugging session
        '';
      };
    };

    sources = mkOption {
      default = {};
      description = "List of debuggers to install";
      type = attrsOf str;
    };

    adapters = mkOption {
      type = attrsOf adapterType;
      default = {};
      description = "Adapter configurations. See `:help dap-adapter`";
    };

    configurations = mkOption {
      type = attrsOf (listOf configurationType);
      default = {};
      description = ''
        Mapping of filetype to list of debuggee configurations.

        See `:help dap-configuration`.
      '';
    };

    mappings = {
      continue = mkMappingOption "Continue" "<leader>dc";
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
