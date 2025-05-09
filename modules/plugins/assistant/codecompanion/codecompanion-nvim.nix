{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) int str enum nullOr attrs;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
in {
  options.vim.assistant = {
    codecompanion-nvim = {
      enable = mkEnableOption "complementary neovim plugin for codecompanion.nvim";

      setupOpts = mkPluginSetupOption "codecompanion-nvim" {
        opts = {
          send_code =
            mkEnableOption ""
            // {
              default = true;
              description = ''
                Whether to enable code being sent to the LLM.
              '';
            };

          log_level = mkOption {
            type = enum ["DEBUG" "INFO" "ERROR" "TRACE"];
            default = "ERROR";
            description = "Change the level of logging.";
          };

          language = mkOption {
            type = str;
            default = "English";
            description = "Specify which language an LLM should respond in.";
          };
        };

        display = {
          diff = {
            enabled =
              mkEnableOption ""
              // {
                default = true;
                description = ''
                  Whether to enable a diff view
                  to see the changes made by the LLM.
                '';
              };

            close_chat_at = mkOption {
              type = int;
              default = 240;
              description = ''
                Close an open chat buffer if the
                total columns of your display are less than...
              '';
            };

            layout = mkOption {
              type = enum ["vertical" "horizontal"];
              default = "vertical";
              description = "Type of split for default provider.";
            };

            provider = mkOption {
              type = enum ["default" "mini_diff"];
              default = "default";
              description = "The preferred kind of provider.";
            };
          };

          inline = {
            layout = mkOption {
              type = enum ["vertical" "horizontal" "buffer"];
              default = "vertical";
              description = "Customize how output is created in new buffer.";
            };
          };

          chat = {
            auto_scroll =
              mkEnableOption ""
              // {
                default = true;
                description = "Whether to enable automatic page scrolling.";
              };

            show_settings = mkEnableOption ''
              LLM settings to appear at the top of the chat buffer.
            '';

            start_in_insert_mode = mkEnableOption ''
              opening the chat buffer in insert mode.
            '';

            show_header_separator = mkEnableOption ''
              header separators in the chat buffer.

              Set this to false if you're using an
              external markdown formatting plugin.
            '';

            show_references =
              mkEnableOption ""
              // {
                default = true;
                description = ''
                  Whether to enable references in the chat buffer.
                '';
              };

            show_token_count =
              mkEnableOption ""
              // {
                default = true;
                description = ''
                  Whether to enable the token count for each response.
                '';
              };

            intro_message = mkOption {
              type = str;
              default = "Welcome to CodeCompanion ✨! Press ? for options.";
              description = "Message to appear in chat buffer.";
            };

            separator = mkOption {
              type = str;
              default = "─";
              description = ''
                The separator between the
                different messages in the chat buffer.
              '';
            };

            icons = {
              pinned_buffer = mkOption {
                type = str;
                default = " ";
                description = "The icon to represent a pinned buffer.";
              };

              watched_buffer = mkOption {
                type = str;
                default = "👀 ";
                description = "The icon to represent a watched buffer.";
              };
            };
          };

          action_palette = {
            width = mkOption {
              type = int;
              default = 95;
              description = "Width of the action palette.";
            };

            height = mkOption {
              type = int;
              default = 10;
              description = "Height of the action palette.";
            };

            prompt = mkOption {
              type = str;
              default = "Prompt ";
              description = "Prompt used for interactive LLM calls.";
            };

            provider = mkOption {
              type = enum ["default" "telescope" "mini_pick"];
              default = "default";
              description = "Provider used for the action palette.";
            };

            opts = {
              show_default_actions =
                mkEnableOption ""
                // {
                  default = true;
                  description = ''
                    Whether to enable showing default
                    actions in the action palette.
                  '';
                };

              show_default_prompt_library =
                mkEnableOption ""
                // {
                  default = true;
                  description = ''
                    Whether to enable showing default
                    prompt library in the action palette.
                  '';
                };
            };
          };
        };

        adapters = mkOption {
          type = nullOr luaInline;
          default = null;
          description = "An adapter is what connects Neovim to an LLM.";
        };

        strategies = {
          chat = {
            adapter = mkOption {
              type = nullOr str;
              default = null;
              description = "Adapter used for the chat strategy.";
            };

            keymaps = mkOption {
              type = nullOr attrs;
              default = null;
              description = "Define or override the default keymaps.";
            };

            variables = mkOption {
              type = nullOr luaInline;
              default = null;
              description = ''
                Define your own variables
                to share specific content.
              '';
            };

            slash_commands = mkOption {
              type = nullOr luaInline;
              default = null;
              description = ''
                Slash Commands (invoked with /) let you dynamically
                insert context into the chat buffer,
                such as file contents or date/time.
              '';
            };

            tools = mkOption {
              type = nullOr attrs;
              default = null;
              description = ''
                Configure tools to perform specific
                tasks when invoked by an LLM.
              '';
            };

            roles = mkOption {
              type = nullOr luaInline;
              default = null;
              description = ''
                The chat buffer places user and LLM responses under a H2 header.
                These can be customized in the configuration.
              '';
            };
          };

          inline = {
            adapter = mkOption {
              type = nullOr str;
              default = null;
              description = "Adapter used for the inline strategy.";
            };

            variables = mkOption {
              type = nullOr luaInline;
              default = null;
              description = ''
                Define your own variables
                to share specific content.
              '';
            };

            keymaps = {
              accept_change = {
                n = mkOption {
                  type = str;
                  default = "ga";
                  description = "Accept the suggested change.";
                };
              };

              reject_change = {
                n = mkOption {
                  type = str;
                  default = "gr";
                  description = "Reject the suggested change.";
                };
              };
            };
          };
        };

        prompt_library = mkOption {
          type = nullOr attrs;
          default = null;
          description = ''
            A prompt library is a collection of prompts
            that can be used in the action palette.
          '';
        };
      };
    };
  };
}
