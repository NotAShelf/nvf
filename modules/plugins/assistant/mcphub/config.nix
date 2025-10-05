{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.assistant.mcphub-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "plenary-nvim"
      ];

      lazy.plugins = {
        mcphub-nvim = {
          package = "mcphub-nvim";
          setupModule = "mcphub";
          inherit (cfg) setupOpts;
          event = ["DeferredUIEnter"];
        };
      };

      # avante-nvim
      assistant.avante-nvim.setupOpts = {
        system_prompt = lib.generators.mkLuaInline ''
          function()
                    local hub = require("mcphub").get_hub_instance()
                    return hub and hub:get_active_servers_prompt() or ""
          end
        '';
        custom_tools = lib.generators.mkLuaInline ''
          function()
                  return {
                      require("mcphub.extensions.avante").mcp_tool(),
                  }
          end
        '';
      };

      # codecompanion-nvim
      assistant.codecompanion-nvim.setupOpts.extensions.mcphub = {
        callback = "mcphub.extensions.codecompanion";
        opts = {
          ## MCP Tools
          make_tools = true;
          show_server_tools_in_chat = true;
          add_mcp_prefix_to_tool_names = false;
          show_result_in_chat = true;
          format_tool = null;
          ## MCP Resources
          make_vars = true;
          ## MCP Prompts
          make_slash_commands = true;
        };
      };

      # lualine
      statusline.lualine.setupOpts.sections.lualine_x = lib.generators.mkLuaInline ''
        {{
           function()
               -- Check if MCPHub is loaded
               if not vim.g.loaded_mcphub then
                   return "󰐻 -"
               end

               local count = vim.g.mcphub_servers_count or 0
               local status = vim.g.mcphub_status or "stopped"
               local executing = vim.g.mcphub_executing

               -- Show "-" when stopped
               if status == "stopped" then
                   return "󰐻 -"
               end

               -- Show spinner when executing, starting, or restarting
               if executing or status == "starting" or status == "restarting" then
                   local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
                   local frame = math.floor(vim.loop.now() / 100) % #frames + 1
                   return "󰐻 " .. frames[frame]
               end

               return "󰐻 " .. count
           end,
           color = function()
               if not vim.g.loaded_mcphub then
                   return { fg = "#6c7086" } -- Gray for not loaded
               end

               local status = vim.g.mcphub_status or "stopped"
               if status == "ready" or status == "restarted" then
                   return { fg = "#50fa7b" } -- Green for connected
               elseif status == "starting" or status == "restarting" then
                   return { fg = "#ffb86c" } -- Orange for connecting
               else
                   return { fg = "#ff5555" } -- Red for error/stopped
               end
           end,
           },}
      '';
    };
  };
}
