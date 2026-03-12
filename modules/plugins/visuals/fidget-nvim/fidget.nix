{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkRemovedOptionModule mkRenamedOptionModule;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.strings) toUpper;
  inherit (lib.types) int float bool str enum listOf attrsOf oneOf nullOr submodule;
  inherit (lib.trivial) warn;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline borderType;
  inherit (lib.generators) mkLuaInline;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "visuals" "fidget-nvim" "align" "bottom"] ["vim" "visuals" "fidget-nvim" "setupOpts" "notification" "window" "align"])
    (mkRemovedOptionModule ["vim" "visuals" "fidget-nvim" "align" "right"] ''
      Option `vim.fidget-nvim.align.right` has been removed and does not have an
      equivalent replacement in rewritten fidget.nvim configuration. Please remove
      it from your configuration.
    '')
  ];

  options.vim.visuals.fidget-nvim = {
    enable = mkEnableOption "nvim LSP UI element [fidget-nvim]";

    setupOpts = mkPluginSetupOption "Fidget" {
      progress = {
        poll_rate = mkOption {
          type = int;
          default = 0;
          description = "How frequently to poll for LSP progress messages";
        };
        suppress_on_insert = mkOption {
          type = bool;
          default = false;
          description = "Suppress new messages when in insert mode";
        };
        ignore_done_already = mkOption {
          type = bool;
          default = false;
          description = "Ignore new tasks that are already done";
        };
        ignore_empty_message = mkOption {
          type = bool;
          default = false;
          description = "Ignore new tasks with empty messages";
        };
        notification_group = mkOption {
          type = luaInline;
          default = mkLuaInline ''
            function(msg)
              return msg.lsp_client.name
            end
          '';
          description = "How to get a progress message's notification group key";
        };
        clear_on_detach = mkOption {
          type = nullOr luaInline;
          default = mkLuaInline ''
            function(client_id)
              local client = vim.lsp.get_client_by_id(client_id)
              return client and client.name or nil
            end
          '';
          description = "Clear notification group when LSP server detaches";
        };
        ignore = mkOption {
          type = listOf str;
          default = [];
          description = "Ignore LSP servers by name";
        };

        display = {
          render_limit = mkOption {
            type = int;
            default = 16;
            description = "Maximum number of messages to render";
          };
          done_ttl = mkOption {
            type = int;
            default = 3;
            description = "How long a message should persist when complete";
          };
          done_icon = mkOption {
            type = str;
            default = "✓";
            description = "Icon shown when LSP progress tasks are completed";
          };
          done_style = mkOption {
            type = str;
            default = "Constant";
            description = "Highlight group for completed LSP tasks";
          };
          progress_ttl = mkOption {
            type = int;
            default = 99999;
            description = "How long a message should persist when in progress";
          };
          progress_icon = {
            pattern = mkOption {
              type = enum [
                "dots"
                "dots_negative"
                "dots_snake"
                "dots_footsteps"
                "dots_hop"
                "line"
                "pipe"
                "dots_ellipsis"
                "dots_scrolling"
                "star"
                "flip"
                "hamburger"
                "grow_vertical"
                "grow_horizontal"
                "noise"
                "dots_bounce"
                "triangle"
                "arc"
                "circle"
                "square_corners"
                "circle_quarters"
                "circle_halves"
                "dots_toggle"
                "box_toggle"
                "arrow"
                "zip"
                "bouncing_bar"
                "bouncing_ball"
                "clock"
                "earth"
                "moon"
                "dots_pulse"
                "meter"
              ];
              default = "dots";
              description = "Pattern shown when LSP progress tasks are in progress";
            };
            period = mkOption {
              type = int;
              default = 1;
              description = "Period of the pattern";
            };
          };
          progress_style = mkOption {
            type = str;
            default = "WarningMsg";
            description = "Highlight group for in-progress LSP tasks";
          };
          group_style = mkOption {
            type = str;
            default = "Title";
            description = "Highlight group for group name (LSP server name)";
          };
          icon_style = mkOption {
            type = str;
            default = "Question";
            description = "Highlight group for group icons";
          };
          priority = mkOption {
            type = int;
            default = 30;
            description = "Priority of the progress notification";
          };
          skip_history = mkOption {
            type = bool;
            default = true;
            description = "Skip adding messages to history";
          };
          format_message = mkOption {
            type = luaInline;
            default = mkLuaInline ''
              require("fidget.progress.display").default_format_message
            '';
            description = "How to format a progress message";
          };
          format_annote = mkOption {
            type = luaInline;
            default = mkLuaInline ''
              function(msg) return msg.title end
            '';
            description = "How to format a progress annotation";
          };
          format_group_name = mkOption {
            type = luaInline;
            default = mkLuaInline ''
              function(group) return tostring(group) end
            '';
            description = "How to format a progress notification group's name";
          };
          overrides = mkOption {
            type = attrsOf (submodule {
              options = {
                name = mkOption {
                  type = nullOr (oneOf [str luaInline]);
                  default = null;
                  description = ''
                    Name of the group, displayed in the notification window.
                    Can be a string or a function that returns a string.

                    If a function, it is invoked every render cycle with the items
                    list, useful for rendering animations and other dynamic content.

                    ::: {.note}
                    If you're looking for detailed information into the function
                    signature, you can refer to the fidget API documentation available
                    [here](https://github.com/j-hui/fidget.nvim/blob/1ba38e4cbb24683973e00c2e36f53ae64da38ef5/doc/fidget-api.txt#L70-L77)
                    :::
                  '';
                };
                icon = mkOption {
                  type = nullOr (oneOf [str luaInline]);
                  default = null;
                  description = ''
                    Icon of the group, displayed in the notification window.
                    Can be a string or a function that returns a string.

                    If a function, it is invoked every render cycle with the items
                    list, useful for rendering animations and other dynamic content.

                    ::: {.note}
                    If you're looking for detailed information into the function
                    signature, you can refer to the fidget API documentation available
                    [here](https://github.com/j-hui/fidget.nvim/blob/1ba38e4cbb24683973e00c2e36f53ae64da38ef5/doc/fidget-api.txt#L70-L77)
                    :::
                  '';
                };
                icon_on_left = mkOption {
                  type = nullOr bool;
                  default = null;
                  description = "If true, icon is rendered on the left instead of right";
                };
                annote_separator = mkOption {
                  type = nullOr str;
                  default = " ";
                  description = "Separator between message from annote";
                };
                ttl = mkOption {
                  type = nullOr int;
                  default = 5;
                  description = "How long a notification item should exist";
                };
                render_limit = mkOption {
                  type = nullOr int;
                  default = null;
                  description = "How many notification items to show at once";
                };
                group_style = mkOption {
                  type = nullOr str;
                  default = "Title";
                  description = "Style used to highlight group name";
                };
                icon_style = mkOption {
                  type = nullOr str;
                  default = null;
                  description = "Style used to highlight icon, if null, use group_style";
                };
                annote_style = mkOption {
                  type = nullOr str;
                  default = "Question";
                  description = "Default style used to highlight item annotes";
                };
                debug_style = mkOption {
                  type = nullOr str;
                  default = null;
                  description = "Style used to highlight debug item annotes";
                };
                info_style = mkOption {
                  type = nullOr str;
                  default = null;
                  description = "Style used to highlight info item annotes";
                };
                warn_style = mkOption {
                  type = nullOr str;
                  default = null;
                  description = "Style used to highlight warn item annotes";
                };
                error_style = mkOption {
                  type = nullOr str;
                  default = null;
                  description = "Style used to highlight error item annotes";
                };
                debug_annote = mkOption {
                  type = nullOr str;
                  default = null;
                  description = "Default annotation for debug items";
                };
                info_annote = mkOption {
                  type = nullOr str;
                  default = null;
                  description = "Default annotation for info items";
                };
                warn_annote = mkOption {
                  type = nullOr str;
                  default = null;
                  description = "Default annotation for warn items";
                };
                error_annote = mkOption {
                  type = nullOr str;
                  default = null;
                  description = "Default annotation for error items";
                };
                priority = mkOption {
                  type = nullOr int;
                  default = 50;
                  description = "Order in which group should be displayed";
                };
                skip_history = mkOption {
                  type = nullOr bool;
                  default = null;
                  description = "Whether messages should be preserved in history";
                };
                update_hook = mkOption {
                  type = nullOr (oneOf [bool luaInline]);
                  default = false;
                  description = ''
                    Called when an item is updated.

                    If false, no action is taken.
                    If a function, it is invoked with the item being updated.

                    ::: {.note}
                    If you're looking for detailed information into the function
                    signature, you can refer to the fidget API documentation available
                    [here](https://github.com/j-hui/fidget.nvim/blob/1ba38e4cbb24683973e00c2e36f53ae64da38ef5/doc/fidget-api.txt#L114)
                    :::
                  '';
                };
              };
            });
            default = {};
            example = literalExpression ''
              {
                rust_analyzer = {
                  name = "Rust Analyzer";
                };
              }
            '';
            description = ''
              Overrides the default configuration for a notification group defined
              in {option}`vim.visuals.fidget-nvim.setupOpts.notification.configs`.

              If any of the fields are null, the value from the default
              configuration is used.

              If default configuration is not defined, the following defaults are used:
              ```lua
                 {
                     name = "Notifications",
                     icon = "❰❰",
                     ttl = 5,
                     group_style = "Title",
                     icon_style = "Special",
                     annote_style = "Question",
                     debug_style = "Comment",
                     info_style = "Question",
                     warn_style = "WarningMsg",
                     error_style = "ErrorMsg",
                     debug_annote = "DEBUG",
                     info_annote = "INFO",
                     warn_annote = "WARN",
                     error_annote = "ERROR",
                     update_hook = function(item)
                       notification.set_content_key(item)
                     end,
                 }
              ```
            '';
          };
        };

        lsp = {
          progress_ringbuf_size = mkOption {
            type = int;
            default = 100;
            description = "Nvim's LSP client ring buffer size";
          };
          log_handler = mkOption {
            type = bool;
            default = false;
            description = "Log `$/progress` handler invocations";
          };
        };
      };

      notification = {
        poll_rate = mkOption {
          type = int;
          default = 10;
          description = "How frequently to update and render notifications";
        };
        filter = mkOption {
          type = enum ["debug" "info" "warn" "error"];
          default = "info";
          description = "Minimum notifications level";
          apply = filter: mkLuaInline "vim.log.levels.${toUpper filter}";
        };
        history_size = mkOption {
          type = int;
          default = 128;
          description = "Number of removed messages to retain in history";
        };
        override_vim_notify = mkOption {
          type = bool;
          default = false;
          description = "Automatically override vim.notify() with Fidget";
        };
        configs = mkOption {
          type = attrsOf luaInline;
          default = {default = mkLuaInline "require('fidget.notification').default_config";};
          description = "How to configure notification groups when instantiated";
        };
        redirect = mkOption {
          type = luaInline;
          default = mkLuaInline ''
            function(msg, level, opts)
              if opts and opts.on_open then
                return require("fidget.integration.nvim-notify").delegate(msg, level, opts)
              end
            end
          '';
          description = "Conditionally redirect notifications to another backend";
        };

        view = {
          stack_upwards = mkOption {
            type = bool;
            default = true;
            description = "Display notification items from bottom to top";
          };
          align = mkOption {
            type = enum ["message" "annote"];
            default = "message";
            description = "Indent messages longer than a single line";
          };
          reflow = mkOption {
            type = enum ["hard" "hyphenate" "ellipsis" "false"];
            default = "false";
            description = ''
              Reflow (wrap) messages wider than notification window

              The various options determine how wrapping is handled mid-word.
            '';
          };
          icon_separator = mkOption {
            type = str;
            default = " ";
            description = "Separator between group name and icon";
          };
          group_separator = mkOption {
            type = str;
            default = "---";
            description = "Separator between notification groups";
          };
          group_separator_hl = mkOption {
            type = str;
            default = "Comment";
            description = "Highlight group used for group separator";
          };
          line_margin = mkOption {
            type = int;
            default = 1;
            description = ''
              Spaces to pad both sides of each non-empty line

              Useful for adding a visual gap between notification text
              and any buffer it may overlap with.
            '';
          };
          render_message = mkOption {
            type = luaInline;
            default = mkLuaInline ''
              function(msg, cnt)
                return cnt == 1 and msg or string.format("(%dx) %s", cnt, msg)
              end
            '';
            description = "How to render notification messages";
          };
        };

        window = {
          normal_hl = mkOption {
            type = str;
            default = "Comment";
            description = "Base highlight group in the notification window";
          };
          winblend = mkOption {
            type = int;
            default = 100;
            description = "Background color opacity in the notification window";
          };
          border = mkOption {
            type = borderType;
            default =
              if config.vim.ui.borders.enable
              then config.vim.ui.borders.globalStyle
              else "none";
            description = "Border style of the notification window";
          };
          border_hl = mkOption {
            type = str;
            default = "";
            description = ''
              Highlight group for notification window border

              Set to empty string to keep your theme's default `FloatBorder` highlight.
            '';
          };
          zindex = mkOption {
            type = int;
            default = 45;
            description = "Stacking priority of the notification window";
          };
          max_width = mkOption {
            type = int;
            default = 0;
            description = "Maximum width of the notification window";
          };
          max_height = mkOption {
            type = int;
            default = 0;
            description = "Maximum height of the notification window";
          };
          x_padding = mkOption {
            type = int;
            default = 1;
            description = "Padding from right edge of window boundary";
          };
          y_padding = mkOption {
            type = int;
            default = 0;
            description = "Padding from bottom edge of window boundary";
          };
          align = mkOption {
            type = enum ["top" "bottom"];
            default = "bottom";
            description = "How to align the notification window";
          };
          relative = mkOption {
            type = enum ["editor" "win"];
            default = "editor";
            description = "What the notification window position is relative to";
          };
          tabstop = mkOption {
            type = int;
            default = 8;
            description = "Width of each tab character in the notification window";
          };
          avoid = mkOption {
            type = listOf str;
            default = [];
            description = "Filetypes the notification window should avoid";
          };
        };
      };

      integration = {
        nvim-tree = {
          enable = mkOption {
            type = bool;
            default = false;
            description = "Integrate with nvim-tree/nvim-tree.lua (if enabled)";
            visible = false;
            apply = warn ''
              Option `vim.visuals.fidget-nvim.setupOpts.integration.nvim-tree.enable`
              has been deprecated upstream. Use
              `vim.visuals.fidget-nvim.setupOpts.notification.window.avoid = ["NvimTree"]` instead.
              This is already set if `vim.filetree.nvimTree.enable == true`.
            '';
          };
        };
        xcodebuild-nvim = {
          enable = mkOption {
            type = bool;
            default = false;
            description = "Integrate with wojciech-kulik/xcodebuild.nvim (if enabled)";
            visible = false;
            apply = warn ''
              Option `vim.visuals.fidget-nvim.setupOpts.integration.xcodebuild-nvim.enable`
              has been deprecated upstream. Use
              `vim.visuals.fidget-nvim.setupOpts.notification.window.avoid = ["TestExplorer"]` instead.
            '';
          };
        };
      };

      logger = {
        level = mkOption {
          type = enum ["debug" "error" "info" "trace" "warn" "off"];
          default = "warn";
          description = "Minimum logging level";
          apply = logLevel: mkLuaInline "vim.log.levels.${toUpper logLevel}";
        };
        max_size = mkOption {
          type = int;
          default = 10000;
          description = "Maximum log file size, in KB";
        };
        float_precision = mkOption {
          type = float;
          default = 0.01;
          description = "Limit the number of decimals displayed for floats";
        };
        path = mkOption {
          type = luaInline;
          default = mkLuaInline ''
            string.format("%s/fidget.nvim.log", vim.fn.stdpath("cache"))
          '';
          description = "Where Fidget writes its logs to";
        };
      };
    };
  };
}
