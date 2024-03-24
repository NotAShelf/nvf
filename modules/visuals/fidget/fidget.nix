{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkRemovedOptionModule mkRenamedOptionModule;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.strings) toUpper;
  inherit (lib.types) int float bool str enum listOf attrsOf;
  inherit (lib.nvim.types) mkPluginSetupOption;

  rawLua = lua: {__raw = lua;};
in {
  imports = [
    (mkRenamedOptionModule ["vim" "visuals" "fidget-nvim" "align" "bottom"] ["vim" "visuals" "fidget-nvim" "setupOpts" "notification" "window" "align"])
    (mkRemovedOptionModule ["vim" "visuals" "fidget-nvim" "align" "right"]
      "Option `vim.fidget-nvim.align.right` has been removed and does not have an equivalent replacement in rewritten fidget.nvim configuration.")
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
        clear_on_detach = mkOption {
          description = "Clear notification group when LSP server detaches";
          type = bool;
          default = true;
          apply = clear:
            if clear
            then
              rawLua ''
                function(client_id)
                  local client = vim.lsp.get_client_by_id(client_id)
                  return client and client.name or nil
                end
              ''
            else null;
        };
        notification_group = mkOption {
          description = "How to get a progress message's notification group key";
          type = str;
          default = ''
            function(msg)
              return msg.lsp_client.name
            end
          '';
          apply = rawLua;
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
            type = str;
            default = ''
              require("fidget.progress.display").default_format_message
            '';
            apply = rawLua;
          };
          format_annote = mkOption {
            description = "How to format a progress annotation";
            type = str;
            default = ''
              function(msg) return msg.title end
            '';
            apply = rawLua;
          };
          format_group_name = mkOption {
            description = "How to format a progress notification group's name";
            type = str;
            default = ''
              function(group) return tostring(group) end
            '';
            apply = rawLua;
          };
          overrides = mkOption {
            description = "Override options from the default notification config";
            type = attrsOf str;
            default = {rust_analyzer = "{ name = 'rust-analyzer' }";};
            apply = mapAttrs (key: lua: rawLua lua);
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
          apply = filter: rawLua "vim.log.levels.${toUpper filter}";
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
          type = attrsOf str;
          default = {default = "require('fidget.notification').default_config";};
          apply = mapAttrs (key: lua: rawLua lua);
        };
        redirect = mkOption {
          description = "Conditionally redirect notifications to another backend";
          type = str;
          default = ''
            function(msg, level, opts)
              if opts and opts.on_open then
                return require("fidget.integration.nvim-notify").delegate(msg, level, opts)
              end
            end
          '';
          apply = rawLua;
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
            type = str;
            default = ''
              function(msg, cnt)
                return cnt == 1 and msg or string.format("(%dx) %s", cnt, msg)
              end
            '';
            apply = rawLua;
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
            type = enum ["none" "single" "double" "rounded" "solid" "shadow"];
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
          apply = logLevel: rawLua "vim.log.levels.${toUpper logLevel}";
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
          type = str;
          default = ''
            string.format("%s/fidget.nvim.log", vim.fn.stdpath("cache"))
          '';
          apply = rawLua;
        };
      };
    };
  };
}
