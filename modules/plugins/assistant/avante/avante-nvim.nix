{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption literalMD;
  inherit (lib.types) int str enum nullOr attrs either;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
in {
  options.vim.assistant = {
    avante-nvim = {
      enable = mkEnableOption "complementary neovim plugin for avante.nvim";
      setupOpts = mkPluginSetupOption "avante-nvim" {
        provider = mkOption {
          type = nullOr str;
          default = null;
          description = "The provider used in Aider mode or in the planning phase of Cursor Planning Mode.";
        };

        vendors = mkOption {
          type = nullOr attrs;
          default = null;
          description = "Define Your Custom providers.";
          example = literalMD ''
            ```nix
            ollama = {
              __inherited_from = "openai";
              api_key_name = "";
              endpoint = "http://127.0.0.1:11434/v1";
              model = "qwen2.5u-coder:7b";
              max_tokens = 4096;
              disable_tools = true;
            };
            ollama_ds = {
              __inherited_from = "openai";
              api_key_name = "";
              endpoint = "http://127.0.0.1:11434/v1";
              model = "deepseek-r1u:7b";
              max_tokens = 4096;
              disable_tools = true;
            };
            ```
          '';
        };

        auto_suggestions_provider = mkOption {
          type = str;
          default = "claude";
          description = ''
            Since auto-suggestions are a high-frequency operation and therefore expensive,
            currently designating it as `copilot` provider is dangerous because: https://github.com/yetone/avante.nvim/issues/1048
            Of course, you can reduce the request frequency by increasing `suggestion.debounce`.
          '';
        };

        cursor_applying_provider = mkOption {
          type = nullOr str;
          default = null;
          description = ''
            The provider used in the applying phase of Cursor Planning Mode, defaults to nil,
            when nil uses Config.provider as the provider for the applying phase
          '';
        };

        dual_boost = {
          enabled =
            mkEnableOption ""
            // {
              default = false;
              description = ''
                enable/disable dual boost.
              '';
            };

          first_provider = mkOption {
            type = str;
            default = "openai";
          };

          second_provider = mkOption {
            type = str;
            default = "claude";
          };

          prompt = mkOption {
            type = str;
            default = "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]";
          };

          timeout = mkOption {
            type = int;
            default = 60000;
            description = "Timeout in milliseconds.";
          };
        };

        behaviour = {
          auto_suggestions =
            mkEnableOption ""
            // {
              default = false;
            };

          auto_set_highlight_group =
            mkEnableOption ""
            // {
              default = true;
            };

          auto_set_keymaps =
            mkEnableOption ""
            // {
              default = true;
            };

          auto_apply_diff_after_generation =
            mkEnableOption ""
            // {
              default = false;
            };

          support_paste_from_clipboard =
            mkEnableOption ""
            // {
              default = false;
            };

          minimize_diff =
            mkEnableOption ""
            // {
              default = true;
              description = "Whether to remove unchanged lines when applying a code block.";
            };

          enable_token_counting =
            mkEnableOption ""
            // {
              default = true;
              description = "Whether to enable token counting. Default to true.";
            };

          enable_cursor_planning_mode =
            mkEnableOption ""
            // {
              default = false;
              description = "Whether to enable Cursor Planning Mode. Default to false.";
            };

          enable_claude_text_editor_tool_mode =
            mkEnableOption ""
            // {
              default = false;
              description = "Whether to enable Claude Text Editor Tool Mode.";
            };
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
            enabled =
              mkEnableOption ""
              // {
                default = true;
                description = ''
                  enable/disable the header.
                '';
              };

            align = mkOption {
              type = enum ["right" "center" "left"];
              default = "center";
              description = "Position of the title.";
            };

            rounded =
              mkEnableOption ""
              // {
                default = true;
              };
          };

          input = {
            prefix = mkOption {
              type = str;
              default = "> ";
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
            };

            start_insert =
              mkEnableOption ""
              // {
                default = true;
                description = ''
                  Start insert mode when opening the edit window.
                '';
              };
          };

          ask = {
            floating =
              mkEnableOption ""
              // {
                default = false;
                description = ''
                  Open the 'AvanteAsk' prompt in a floating window.
                '';
              };

            start_insert =
              mkEnableOption ""
              // {
                default = true;
                description = ''
                  Start insert mode when opening the ask window.
                '';
              };

            border = mkOption {
              type = str;
              default = "rounded";
            };

            focus_on_apply = mkOption {
              type = enum ["ours" "theirs"];
              default = "ours";
              description = "which diff to focus after applying.";
            };
          };
        };

        highlights = {
          diff = {
            current = mkOption {
              type = str;
              default = "DiffText";
            };

            incoming = mkOption {
              type = str;
              default = "DiffAdd";
            };
          };
        };

        diff = {
          autojump =
            mkEnableOption ""
            // {
              default = true;
            };

          list_opener = mkOption {
            type = either str luaInline;
            default = "copen";
          };

          override_timeoutlen = mkOption {
            type = int;
            default = 500;
            description = ''
              Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
              Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
              Disable by setting to -1.
            '';
          };
        };

        suggestion = {
          debounce = mkOption {
            type = int;
            default = 600;
          };

          throttle = mkOption {
            type = int;
            default = 600;
          };
        };
      };
    };
  };
}
