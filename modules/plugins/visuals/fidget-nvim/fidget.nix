{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkRemovedOptionModule mkRenamedOptionModule;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.strings) toUpper;
  inherit (lib.types) int float bool str enum listOf attrsOf oneOf nullOr submodule;
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
          description = "How frequently to poll for LSP progress messages";
          type = int;
          default = 0;
        };
        suppress_on_insert = mkOption {
          description = "Suppress new messages when in insert mode";
          type = bool;
          default = false;
        };
        ignore_done_already = mkOption {
          description = "Ignore new tasks that are already done";
          type = bool;
          default = false;
        };
        ignore_empty_message = mkOption {
          description = "Ignore new tasks with empty messages";
          type = bool;
          default = false;
        };
        notification_group = mkOption {
          description = "How to get a progress message's notification group key";
          type = luaInline;
          default = mkLuaInline ''
            function(msg)
              return msg.lsp_client.name
            end
          '';
        };
        ignore = mkOption {
          description = "Ignore LSP servers by name";
          type = listOf str;
          default = [];
        };

        display = {
          render_limit = mkOption {
            description = "Maximum number of messages to render";
            type = int;
            default = 16;
          };
          done_ttl = mkOption {
            description = "How long a message should persist when complete";
            type = int;
            default = 3;
          };
          done_icon = mkOption {
            description = "Icon shown when LSP progress tasks are completed";
            type = str;
            default = "✓";
          };
          done_style = mkOption {
            description = "Highlight group for completed LSP tasks";
            type = str;
            default = "Constant";
          };
          progress_ttl = mkOption {
            description = "How long a message should persist when in progress";
            type = int;
            default = 99999;
          };
          progress_icon = {
            pattern = mkOption {
              description = "Pattern shown when LSP progress tasks are in progress";
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
            };
            period = mkOption {
              description = "Period of the pattern";
              type = int;
              default = 1;
            };
          };
          progress_style = mkOption {
            description = "Highlight group for in-progress LSP tasks";
            type = str;
            default = "WarningMsg";
          };
          group_style = mkOption {
            description = "Highlight group for group name (LSP server name)";
            type = str;
            default = "Title";
          };
          icon_style = mkOption {
            description = "Highlight group for group icons";
            type = str;
            default = "Question";
          };
          priority = mkOption {
            description = "Priority of the progress notification";
            type = int;
            default = 30;
          };
          skip_history = mkOption {
            description = "Skip adding messages to history";
            type = bool;
            default = true;
          };
          format_message = mkOption {
            description = "How to format a progress message";
            type = luaInline;
            default = mkLuaInline ''
              require("fidget.progress.display").default_format_message
            '';
          };
          format_annote = mkOption {
            description = "How to format a progress annotation";
            type = luaInline;
            default = mkLuaInline ''
              function(msg) return msg.title end
            '';
          };
          format_group_name = mkOption {
            description = "How to format a progress notification group's name";
            type = luaInline;
            default = mkLuaInline ''
              function(group) return tostring(group) end
            '';
          };
          overrides = mkOption {
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
            type = attrsOf (submodule {
              options = {
                name = mkOption {
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
                  type = nullOr (oneOf [str luaInline]);
                  default = null;
                };
                icon = mkOption {
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
                  type = nullOr (oneOf [str luaInline]);
                  default = null;
                };
                icon_on_left = mkOption {
                  description = "If true, icon is rendered on the left instead of right";
                  type = nullOr bool;
                  default = null;
                };
                annote_separator = mkOption {
                  description = "Separator between message from annote";
                  type = nullOr str;
                  default = " ";
                };
                ttl = mkOption {
                  description = "How long a notification item should exist";
                  type = nullOr int;
                  default = 5;
                };
                render_limit = mkOption {
                  description = "How many notification items to show at once";
                  type = nullOr int;
                  default = null;
                };
                group_style = mkOption {
                  description = "Style used to highlight group name";
                  type = nullOr str;
                  default = "Title";
                };
                icon_style = mkOption {
                  description = "Style used to highlight icon, if null, use group_style";
                  type = nullOr str;
                  default = null;
                };
                annote_style = mkOption {
                  description = "Default style used to highlight item annotes";
                  type = nullOr str;
                  default = "Question";
                };
                debug_style = mkOption {
                  description = "Style used to highlight debug item annotes";
                  type = nullOr str;
                  default = null;
                };
                info_style = mkOption {
                  description = "Style used to highlight info item annotes";
                  type = nullOr str;
                  default = null;
                };
                warn_style = mkOption {
                  description = "Style used to highlight warn item annotes";
                  type = nullOr str;
                  default = null;
                };
                error_style = mkOption {
                  description = "Style used to highlight error item annotes";
                  type = nullOr str;
                  default = null;
                };
                debug_annote = mkOption {
                  description = "Default annotation for debug items";
                  type = nullOr str;
                  default = null;
                };
                info_annote = mkOption {
                  description = "Default annotation for info items";
                  type = nullOr str;
                  default = null;
                };
                warn_annote = mkOption {
                  description = "Default annotation for warn items";
                  type = nullOr str;
                  default = null;
                };
                error_annote = mkOption {
                  description = "Default annotation for error items";
                  type = nullOr str;
                  default = null;
                };
                priority = mkOption {
                  description = "Order in which group should be displayed";
                  type = nullOr int;
                  default = 50;
                };
                skip_history = mkOption {
                  description = "Whether messages should be preserved in history";
                  type = nullOr bool;
                  default = null;
                };
                update_hook = mkOption {
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
                  type = nullOr (oneOf [bool luaInline]);
                  default = false;
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
          };
        };

        lsp = {
          progress_ringbuf_size = mkOption {
            description = "Nvim's LSP client ring buffer size";
            type = int;
            default = 100;
          };
          log_handler = mkOption {
            description = "Log `$/progress` handler invocations";
            type = bool;
            default = false;
          };
        };
      };

      notification = {
        poll_rate = mkOption {
          description = "How frequently to update and render notifications";
          type = int;
          default = 10;
        };
        filter = mkOption {
          description = "Minimum notifications level";
          type = enum ["debug" "info" "warn" "error"];
          default = "info";
          apply = filter: mkLuaInline "vim.log.levels.${toUpper filter}";
        };
        history_size = mkOption {
          description = "Number of removed messages to retain in history";
          type = int;
          default = 128;
        };
        override_vim_notify = mkOption {
          description = "Automatically override vim.notify() with Fidget";
          type = bool;
          default = false;
        };
        configs = mkOption {
          description = "How to configure notification groups when instantiated";
          type = attrsOf luaInline;
          default = {default = mkLuaInline "require('fidget.notification').default_config";};
        };
        redirect = mkOption {
          description = "Conditionally redirect notifications to another backend";
          type = luaInline;
          default = mkLuaInline ''
            function(msg, level, opts)
              if opts and opts.on_open then
                return require("fidget.integration.nvim-notify").delegate(msg, level, opts)
              end
            end
          '';
        };

        view = {
          stack_upwards = mkOption {
            description = "Display notification items from bottom to top";
            type = bool;
            default = true;
          };
          icon_separator = mkOption {
            description = "Separator between group name and icon";
            type = str;
            default = " ";
          };
          group_separator = mkOption {
            description = "Separator between notification groups";
            type = str;
            default = "---";
          };
          group_separator_hl = mkOption {
            description = "Highlight group used for group separator";
            type = str;
            default = "Comment";
          };
          render_message = mkOption {
            description = "How to render notification messages";
            type = luaInline;
            default = mkLuaInline ''
              function(msg, cnt)
                return cnt == 1 and msg or string.format("(%dx) %s", cnt, msg)
              end
            '';
          };
        };

        window = {
          normal_hl = mkOption {
            description = "Base highlight group in the notification window";
            type = str;
            default = "Comment";
          };
          winblend = mkOption {
            description = "Background color opacity in the notification window";
            type = int;
            default = 100;
          };
          border = mkOption {
            description = "Border style of the notification window";
            type = borderType;
            default =
              if config.vim.ui.borders.enable
              then config.vim.ui.borders.globalStyle
              else "none";
          };
          zindex = mkOption {
            description = "Stacking priority of the notification window";
            type = int;
            default = 45;
          };
          max_width = mkOption {
            description = "Maximum width of the notification window";
            type = int;
            default = 0;
          };
          max_height = mkOption {
            description = "Maximum height of the notification window";
            type = int;
            default = 0;
          };
          x_padding = mkOption {
            description = "Padding from right edge of window boundary";
            type = int;
            default = 1;
          };
          y_padding = mkOption {
            description = "Padding from bottom edge of window boundary";
            type = int;
            default = 0;
          };
          align = mkOption {
            description = "How to align the notification window";
            type = enum ["top" "bottom"];
            default = "bottom";
          };
          relative = mkOption {
            description = "What the notification window position is relative to";
            type = enum ["editor" "win"];
            default = "editor";
          };
        };
      };

      integration = {
        nvim-tree = {
          enable = mkOption {
            description = "Integrate with nvim-tree/nvim-tree.lua (if enabled)";
            type = bool;
            default =
              if config.vim.filetree.nvimTree.enable
              then true
              else false;
          };
        };
        xcodebuild-nvim = {
          enable = mkOption {
            description = "Integrate with wojciech-kulik/xcodebuild.nvim (if enabled)";
            type = bool;
            default = true;
          };
        };
      };

      logger = {
        level = mkOption {
          description = "Minimum logging level";
          type = enum ["debug" "error" "info" "trace" "warn" "off"];
          default = "warn";
          apply = logLevel: mkLuaInline "vim.log.levels.${toUpper logLevel}";
        };
        max_size = mkOption {
          description = "Maximum log file size, in KB";
          type = int;
          default = 10000;
        };
        float_precision = mkOption {
          description = "Limit the number of decimals displayed for floats";
          type = float;
          default = 0.01;
        };
        path = mkOption {
          description = "Where Fidget writes its logs to";
          type = luaInline;
          default = mkLuaInline ''
            string.format("%s/fidget.nvim.log", vim.fn.stdpath("cache"))
          '';
        };
      };
    };
  };
}
