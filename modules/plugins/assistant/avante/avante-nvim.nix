{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption literalMD;
  inherit (lib.types) int str enum nullOr attrs bool;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.assistant = {
    avante-nvim = {
      enable = mkEnableOption "complementary Neovim plugin for avante.nvim";
      setupOpts = mkPluginSetupOption "avante-nvim" {
        provider = mkOption {
          type = nullOr str;
          default = null;
          description = "The provider used in Aider mode or in the planning phase of Cursor Planning Mode.";
        };

        providers = mkOption {
          type = nullOr attrs;
          default = null;
          description = "Define settings for builtin and custom providers.";
          example = literalMD ''
            ```nix
              openai = {
                endpoint = "https://api.openai.com/v1";
                model = "gpt-4o"; # your desired model (or use gpt-4o, etc.)
                timeout = 30000; # Timeout in milliseconds, increase this for reasoning models
                extra_request_body = {
                  temperature = 0;
                  max_completion_tokens = 8192; # Increase this to include reasoning tokens (for reasoning models)
                  reasoning_effort = "medium"; # low|medium|high, only used for reasoning models
                };
              };
              ollama = {
                endpoint = "http://127.0.0.1:11434";
                timeout = 30000; # Timeout in milliseconds
                extra_request_body = {
                  options = {
                    temperature = 0.75;
                    num_ctx = 20480;
                    keep_alive = "5m";
                  };
                };
              };
              groq = {
                __inherited_from = "openai";
                api_key_name = "GROQ_API_KEY";
                endpoint = "https://api.groq.com/openai/v1/";
                model = "llama-3.3-70b-versatile";
                disable_tools = true;
                extra_request_body = {
                  temperature = 1;
                  max_tokens = 32768; # remember to increase this value, otherwise it will stop generating halfway
                };
              };
            ```
          '';
        };

        auto_suggestions_provider = mkOption {
          type = str;
          default = "claude";
          description = ''
            Since auto-suggestions are a high-frequency operation and therefore expensive,
            currently designating it as `copilot` provider is dangerous because:
            https://github.com/yetone/avante.nvim/issues/1048
            Of course, you can reduce the request frequency by increasing `suggestion.debounce`.
          '';
        };

        cursor_applying_provider = mkOption {
          type = nullOr str;
          default = null;
          description = ''
            The provider used in the applying phase of Cursor Planning Mode, defaults to `nil`,
            Config.provider will be used as the provider for the applying phase when `nil`.
          '';
        };

        dual_boost = {
          enabled = mkEnableOption "dual_boost mode.";

          first_provider = mkOption {
            type = str;
            default = "openai";
            description = "The first provider to generate response.";
          };

          second_provider = mkOption {
            type = str;
            default = "claude";
            description = "The second provider to generate response.";
          };

          prompt = mkOption {
            type = str;
            default = ''
              Based on the two reference outputs below, generate a response that incorporates
              elements from both but reflects your own judgment and unique perspective.
              Do not provide any explanation, just give the response directly. Reference Output 1:
              [{{provider1_output}}], Reference Output 2: [{{provider2_output}}'';
            description = "The prompt to generate response based on the two reference outputs.";
          };

          timeout = mkOption {
            type = int;
            default = 60000;
            description = "Timeout in milliseconds.";
          };
        };

        behaviour = {
          auto_suggestions =
            mkEnableOption "auto suggestions.";

          auto_set_highlight_group =
            mkEnableOption "automatically set the highlight group for the current line."
            // {
              default = true;
            };

          auto_set_keymaps =
            mkEnableOption "automatically set the keymap for the current line."
            // {
              default = true;
            };

          auto_apply_diff_after_generation =
            mkEnableOption "automatically apply diff after LLM response.";

          support_paste_from_clipboard = mkEnableOption ''
            pasting image from clipboard.
            This will be determined automatically based whether img-clip is available or not.
          '';

          minimize_diff =
            mkEnableOption "remove unchanged lines when applying a code block."
            // {
              default = true;
            };

          enable_token_counting =
            mkEnableOption "token counting."
            // {
              default = true;
            };

          enable_cursor_planning_mode =
            mkEnableOption "Cursor Planning Mode.";

          enable_claude_text_editor_tool_mode =
            mkEnableOption "Claude Text Editor Tool Mode.";
        };

        mappings = {
          diff = mkOption {
            type = nullOr attrs;
            default = null;
            description = "Define or override the default keymaps for diff.";
          };

          suggestion = mkOption {
            type = nullOr attrs;
            default = null;
            description = "Define or override the default keymaps for suggestion actions.";
          };

          jump = mkOption {
            type = nullOr attrs;
            default = null;
            description = "Define or override the default keymaps for jump actions.";
          };

          submit = mkOption {
            type = nullOr attrs;
            default = null;
            description = "Define or override the default keymaps for submit actions.";
          };

          cancel = mkOption {
            type = nullOr attrs;
            default = null;
            description = "Define or override the default keymaps for cancel actions.";
          };

          sidebar = mkOption {
            type = nullOr attrs;
            default = null;
            description = "Define or override the default keymaps for sidebar actions.";
          };
        };

        hints.enabled =
          mkEnableOption ""
          // {
            default = true;
            description = ''
              Whether to enable hints.
            '';
          };

        windows = {
          position = mkOption {
            type = enum ["right" "left" "top" "bottom"];
            default = "right";
            description = "The position of the sidebar.";
          };

          wrap =
            mkEnableOption ""
            // {
              default = true;
              description = ''
                similar to vim.o.wrap.
              '';
            };

          width = mkOption {
            type = int;
            default = 30;
            description = "Default % based on available width.";
          };

          sidebar_header = {
            enabled = mkOption {
              type = bool;
              default = true;
              description = "enable/disable the header.";
            };

            align = mkOption {
              type = enum ["right" "center" "left"];
              default = "center";
              description = "Position of the title.";
            };

            rounded = mkOption {
              type = bool;
              default = true;
              description = "Enable rounded sidebar header";
            };
          };

          input = {
            prefix = mkOption {
              type = str;
              default = "> ";
              description = "The prefix used on the user input.";
            };

            height = mkOption {
              type = int;
              default = 8;
              description = ''
                Height of the input window in vertical layout.
              '';
            };
          };

          edit = {
            border = mkOption {
              type = str;
              default = "rounded";
              description = "The border type on the edit window.";
            };

            start_insert = mkOption {
              type = bool;
              default = true;
              description = ''
                Start insert mode when opening the edit window.
              '';
            };
          };

          ask = {
            floating = mkOption {
              type = bool;
              default = false;
              description = ''
                Open the 'AvanteAsk' prompt in a floating window.
              '';
            };

            start_insert = mkOption {
              type = bool;
              default = true;
              description = ''
                Start insert mode when opening the ask window.
              '';
            };

            border = mkOption {
              type = str;
              default = "rounded";
              description = "The border type on the ask window.";
            };

            focus_on_apply = mkOption {
              type = enum ["ours" "theirs"];
              default = "ours";
              description = "Which diff to focus after applying.";
            };
          };
        };

        diff = {
          autojump =
            mkEnableOption ""
            // {
              default = true;
              description = "Automatically jumps to the next change.";
            };

          override_timeoutlen = mkOption {
            type = int;
            default = 500;
            example = -1;
            description = ''
              Override the 'timeoutlen' setting while hovering over a diff (see {command}`:help timeoutlen`).
              Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
              Disable by setting to -1.
            '';
          };
        };

        suggestion = {
          debounce = mkOption {
            type = int;
            default = 600;
            description = "Suggestion debounce in milliseconds.";
          };

          throttle = mkOption {
            type = int;
            default = 600;
            description = "Suggestion throttle in milliseconds.";
          };
        };
      };
    };
  };
}
