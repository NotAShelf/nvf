{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption literalMD;
  inherit (lib.types) int bool enum str nullOr attrs listOf either attrsOf anything;
  inherit (lib.strings) toUpper;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
  inherit (lib.generators) mkLuaInline;
in {
  options.vim.assistant = {
    mcphub-nvim = {
      enable = mkEnableOption "MCPHub";

      setupOpts = mkPluginSetupOption "mcphub-nvim" {
        use_bundled_binary =
          mkEnableOption "Use local `mcp-hub` binary."
          // {
            default = true;
          };
        port = mkOption {
          type = int;
          default = 37373;
          description = "The port for the mcp-hub Express server.";
        };

        server_url = mkOption {
          type = nullOr str;
          default = null;
          description = "The URL for the mcp-hub server in cases where it is hosted somewhere else.";
          example = "http://mydomain.com:8080";
        };

        config_path = mkOption {
          type = str;
          default = "~/.config/mcphub/servers.json";
          description = "The absolute path to your mcpservers.json configuration file. Defaults to ~/.config/mcphub/servers.json in Lua.";
          example = "~/.config/nvim/mcpservers.json";
        };

        shutdown_delay = mkOption {
          type = int;
          default = 300000; # 5 minutes in milliseconds
          description = "The delay in milliseconds before the server shuts down when the last client disconnects.";
        };

        request_timeout = mkOption {
          type = int;
          default = 60000;
          description = "Timeout for MCP requests in milliseconds.";
        };

        auto_approve = mkOption {
          type = either luaInline bool;
          default = false;
          description = ''
            How to approve MCP calls.

            The system checks auto-approval in this order:
             1. Function: Custom auto_approve function (if provided)
             1. Server-specific: autoApprove field in server config
             1. Default: Show confirmation dialog
          '';
        };

        auto_toggle_servers =
          mkEnableOption "Let LLMs start and stop MCP servers automatically."
          // {
            default = true;
          };

        cmd = mkOption {
          type = nullOr str;
          default = null;
          description = "Custom command to start the mcp-hub binary.";
        };

        cmd_args = mkOption {
          type = nullOr (listOf str);
          default = null;
          description = "Custom arguments for the mcp-hub command.";
        };

        global_env = mkOption {
          type = nullOr (either luaInline (attrsOf anything));
          default = null;
          description = ''
            Global environment variables available to all MCP servers.
            You can use either a table or a function that returns a table.
          '';
        };

        log = {
          level = mkOption {
            description = "Logging level, e.g., 'vim.log.levels.WARN'.";
            type = enum ["debug" "info" "warn" "error" "trace"];
            default = "info";
            apply = filter: mkLuaInline "vim.log.levels.${toUpper filter}";
          };
          to_file = mkEnableOption "log to a file.";
          file_path = mkOption {
            type = nullOr str;
            default = null;
            description = "Path to the log file.";
          };
          prefix = mkOption {
            type = str;
            default = "MCPHub";
            description = "The prefix for log messages.";
          };
        };

        ui = {
          window = mkOption {
            type = attrs;
            default = {
              width = 0.8;
              height = 0.8;
              align = "center";
              relative = "editor";
              zindex = 50;
              border = "rounded";
            };
            description = "Options for the UI window.";
          };
          wo = mkOption {
            type = attrs;
            default = {
              winhl = "Normal:MCPHubNormal,FloatBorder:MCPHubBorder";
            };
            description = "Window options.";
          };
        };

        extensions = {
          avante = {
            enabled =
              mkEnableOption "the Avante extension."
              // {
                default = true;
              };
            make_slash_commands =
              mkEnableOption "create slash commands for Avante."
              // {
                default = true;
              };
          };
          copilotchat = {
            enabled =
              mkEnableOption "the CopilotChat extension."
              // {
                default = true;
              };
            convert_tools_to_functions =
              mkEnableOption "convert tools to functions."
              // {
                default = true;
              };
            convert_resources_to_functions =
              mkEnableOption "convert resources to functions."
              // {
                default = true;
              };
            add_mcp_prefix = mkEnableOption "add an mcp prefix.";
          };
        };

        builtin_tools = {
          edit_file = {
            parser = {
              track_issues =
                mkEnableOption "track issues during parsing."
                // {
                  default = true;
                };
              extract_inline_content =
                mkEnableOption "extract inline content."
                // {
                  default = true;
                };
            };
            locator = {
              fuzzy_threshold = mkOption {
                type = nullOr int;
                default = null;
                description = "Fuzzy matching threshold.";
              };
              enable_fuzzy_matching =
                mkEnableOption "fuzzy matching."
                // {
                  default = true;
                };
            };
            ui = {
              go_to_origin_on_complete =
                mkEnableOption "go to the origin on complete."
                // {
                  default = true;
                };
              keybindings = mkOption {
                type = attrs;
                default = {
                  accept = ".";
                  reject = ",";
                  next = "n";
                  prev = "p";
                  accept_all = "ga";
                  reject_all = "gr";
                };
                description = "Keybindings for the edit file UI.";
              };
            };
          };
        };

        workspace = {
          enabled =
            mkEnableOption "workspace-specific hubs."
            // {
              default = true;
            };
          look_for = mkOption {
            type = listOf str;
            default = [".mcphub/servers.json" ".vscode/mcp.json" ".cursor/mcp.json"];
            description = "Files to search for in order.";
          };
          reload_on_dir_changed =
            mkEnableOption "listen to DirChanged events to reload workspace config."
            // {
              default = true;
            };
          port_range = mkOption {
            type = attrs;
            default = {
              min = 40000;
              max = 41000;
            };
            description = "Port range for workspace hubs, with `min` and `max` attributes.";
          };
          get_port = mkOption {
            type = nullOr luaInline;
            default = null;
            description = "Function that returns the port.";
          };
        };

        on_ready = mkOption {
          type = luaInline;
          default = mkLuaInline ''
            function() end
          '';
          description = ''
            A Lua function to be executed once the mcp-hub server is ready.
            It receives the hub object as an argument.
          '';
          example = literalMD ''
            ```lua
            function(hub)
              vim.notify('MCPHub is ready', vim.log.levels.INFO)
            end
            ```
          '';
        };

        on_error = mkOption {
          type = luaInline;
          default = mkLuaInline ''
            function(msg) end
          '';
          description = ''
            A Lua function to be executed when an error occurs.
            It receives the error message as an argument.
          '';
          example = literalMD ''
            ```lua
            function(msg)
              vim.notify('An error occurred in MCPHub: ' .. msg, vim.log.levels.ERROR)
            end
            ```
          '';
        };
        json_decode = mkOption {
          type = nullOr luaInline;
          default = null;
          description = ''
            Custom JSON parser function for configuration files.

            This is particularly useful for supporting JSON5 syntax (comments and trailing commas).
          '';
        };
      };
    };
  };
}
