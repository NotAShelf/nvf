{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool attrsOf str submodule anything either enum oneOf listOf nullOr int;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
  inherit (config.vim.lib) mkMappingOption;

  commonOptions = {
    initialize_timeout_sec = mkOption {
      type = nullOr int;
      default = null;
      defaultText = "4"; # plugin default
      description = ''
        How many seconds to wait for a response on an initialize request before
        emitting a warning
      '';
    };

    disconnect_timeout_sec = mkOption {
      type = nullOr int;
      default = null;
      defaultText = "3"; # plugin default
      description = ''
        How many seconds to wait for a disconnect response before
        emitting a warning and closing the connection
      '';
    };

    source_filetype = mkOption {
      type = nullOr str;
      default = null;
      description = ''
        The filetype to use for content retrieved via a source request
      '';
    };
  };

  # enrich_config accepted by all adapter types
  enrich_config = mkOption {
    type = nullOr luaInline;
    default = null;
    description = ''
      Used to enrich a configurations with additional information.
      See `:help dap-adapter`.
    '';
  };

  execAdapterType = submodule {
    options = {
      type = mkOption {
        type = enum ["executable"];
      };

      command = mkOption {
        type = str;
        description = "Command to invoke";
      };

      args = mkOption {
        type = listOf str;
      };

      options =
        commonOptions
        // {
          env = mkOption {
            type = nullOr (attrsOf str);
            default = null;
            description = "Environment variables passed to the command";
          };

          cwd = mkOption {
            type = nullOr str;
            default = null;
            description = "Set the working directory for the command";
          };

          detached = mkOption {
            type = nullOr bool;
            default = null;
            defaultText = "true"; # plugin default
            description = ''
              Whether to spawn the debug adapter process in a detached state
            '';
          };
        };

      id = mkOption {
        type = nullOr str;
        default = null;
        description = ''
          Identifier of the adapter. This is used for the `adapterId` property
          of the initialize request.
        '';
      };

      inherit enrich_config;
    };
  };

  serverPipeExecutable = submodule {
    options = {
      command = mkOption {
        type = nullOr str;
        description = "Command that spawns the debug adapter";
      };

      args = mkOption {
        type = nullOr (listOf str);
        default = null;
      };

      detached = mkOption {
        type = nullOr bool;
        default = null;
        defaultText = "true"; # plugin default
        description = ''
          Whether to spawn the debug adapter process in a detached state
        '';
      };

      cwd = mkOption {
        type = nullOr str;
        default = null;
        description = "Working directory";
      };
    };
  };

  serverAdapterType = submodule {
    options = {
      type = mkOption {
        type = enum ["server"];
      };

      host = mkOption {
        type = nullOr str;
        default = null;
        defaultText = "127.0.0.1"; # plugin default
        description = "Host to connect to";
      };

      port = mkOption {
        type = either int (enum ["\${port}"]);
        description = ''
          Port to connect to. Use "''${port}" for a dynamically resolved free
          port. This is intended to be used with executable.args.
        '';
      };

      id = mkOption {
        type = nullOr str;
        default = null;
        description = ''
          Identifier of the adapter. This is used for the `adapterId` property
          of the initialize request.
        '';
      };

      executable = mkOption {
        type = nullOr serverPipeExecutable;
        default = null;
        description = ''
          Optional executable configuration to launch the debug adapter before
          connecting via TCP
        '';
      };

      options =
        commonOptions
        // {
          max_retries = mkOption {
            type = nullOr int;
            default = null;
            defaultText = "14"; # plugin default
            description = ''
              Amount of times the client should attempt to connect before
              erroring out (250ms delay between retries)
            '';
          };
        };

      inherit enrich_config;
    };
  };

  pipeAdapterType = submodule {
    options = {
      type = mkOption {
        type = enum ["pipe"];
      };

      pipe = mkOption {
        type = str;
        description = ''
          Absolute path to the pipe file. Use \"''${pipe}\" for a dynamically
          generated temporary filename
        '';
      };

      executable = mkOption {
        type = nullOr serverPipeExecutable;
        default = null;
        description = ''
          Optional executable configuration to launch the debug adapter before
          connecting via pipe
        '';
      };

      options =
        commonOptions
        // {
          timeout = mkOption {
            type = nullOr int;
            default = null;
            defaultText = "5000"; # plugin default
            description = ''
              Max amount of time in ms to wait between spawning the
              executable and connecting to the pipe
            '';
          };
        };

      inherit enrich_config;
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
      type = attrsOf (oneOf [
        luaInline
        execAdapterType
        serverAdapterType
        pipeAdapterType
      ]);
      default = {};
      description = "Adapter configurations. See `:help dap-adapter`";
    };

    configurations = mkOption {
      type = attrsOf (listOf anything);
      default = {};
      description = ''
        Mapping of filetype to list of possible `Configuration`.

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
