{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
  inherit (lib.types) int bool str enum listOf nullOr;
  inherit (lib.generators) mkLuaInline;
in {
  options.vim.tabline.cokeline = {
    enable = mkEnableOption "cokeline";

    mappings = {
      cycleNext = mkMappingOption "Next buffer" "<Tab>";
      cyclePrevious = mkMappingOption "Previous buffer" "<S-Tab>";
      pick = mkMappingOption "Pick buffer" "<leader>bc";
      switchNext = mkMappingOption "Switch with next buffer" "<leader>bmn";
      switchPrevious = mkMappingOption "Move previous buffer" "<leader>bmp";
      closeByLetter = mkMappingOption "Close buffer by letter" "<leader>bd";
    };

    setupOpts = mkPluginSetupOption "Cokeline" {
      show_if_buffers_are_at_least = mkOption {
        description = "Only show the bufferline when there are at least this many visible buffers";
        type = int;
        default = 0;
      };

      buffers = {
        filter_valid = mkOption {
          description = "Only show valid buffers in the bufferline";
          type = bool;
          default = false;
        };
        filter_visible = mkOption {
          description = "Only show visible buffers in the bufferline";
          type = bool;
          default = false;
        };
        focus_on_delete = mkOption {
          description = "Focus on buffer deletion";
          type = enum ["prev" "next"];
          default = "next";
        };
        new_buffers_position = mkOption {
          description = "Position of new buffers";
          type = enum ["last" "next" "directory" "number"];
          default = "last";
        };
        delete_on_right_click = mkOption {
          description = "Delete buffer on right click";
          type = bool;
          default = true;
        };
      };

      mappings = {
        cycle_prev_next = mkOption {
          description = "If true, the last (first) buffer gets focused/switched, if false, nothing happens";
          type = bool;
          default = true;
        };
        disable_mouse = mkOption {
          description = "Disable mouse mappings";
          type = bool;
          default = false;
        };
      };

      history = {
        enable = mkOption {
          description = "Enable a history of focused buffers using a ringbuffer";
          type = bool;
          default = true;
        };
        size = mkOption {
          description = "The maximum number of items to keep in the history";
          type = int;
          default = 2;
        };
      };

      rendering = {
        max_buffer_width = mkOption {
          description = "The maximum number of characters a rendered buffer is allowed to take up. The buffer will be truncated if its width is bigger than this value.";
          type = int;
          default = 999;
        };
      };

      pick = {
        use_filename = mkOption {
          description = "Whether to use the filename's first letter first before picking a letter from the valid letters list in order.";
          type = bool;
          default = true;
        };
        letters = mkOption {
          description = "The list of letters that are valid as pick letters. Sorted by keyboard reachability by default, but may require tweaking for non-QWERTY keyboard layouts.";
          type = str;
          default = "asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERTYQP";
        };
      };

      default_hl = {
        fg = mkOption {
          description = "The default foreground color for buffers";
          type = luaInline;
          default = mkLuaInline ''
            function(buffer)
              return
                buffer.is_focused
                and vim.api.nvim_get_hl_by_name('Normal', true).foreground
                or vim.api.nvim_get_hl_by_name('Comment', true).foreground
            end
          '';
        };
        bg = mkOption {
          description = "The default background color for buffers";
          type = luaInline;
          default = mkLuaInline ''
            function(buffer)
              return vim.api.nvim_get_hl_by_name('ColorColumn', true).background
            end
          '';
        };
        sp = mkOption {
          description = "The default special key color for buffers";
          type = nullOr luaInline;
          default = null;
        };
        bold = mkOption {
          description = "The default bold attribute for buffers";
          type = nullOr luaInline;
          default = null;
        };
        italic = mkOption {
          description = "The default italic attribute for buffers";
          type = nullOr luaInline;
          default = null;
        };
        underline = mkOption {
          description = "The default underline attribute for buffers";
          type = nullOr luaInline;
          default = null;
        };
        undercurl = mkOption {
          description = "The default undercurl attribute for buffers";
          type = nullOr luaInline;
          default = null;
        };
        strikethrough = mkOption {
          description = "The default strikethrough attribute for buffers";
          type = nullOr luaInline;
          default = null;
        };
      };

      fill_hl = mkOption {
        description = "The highlight group used to fill the tabline space";
        type = str;
        default = "TabLineFill";
      };

      tabs = {
        placement = mkOption {
          description = "The position of the tabline";
          type = enum ["left" "right"];
          default = "left";
        };
      };

      sidebar = {
        filetype = mkOption {
          description = "The filetype of the sidebar";
          type = listOf str;
          default = ["NvimTree" "neo-tree" "SidebarNvim"];
        };
      };

      # components = mkOption {
      #   description = "The components to use in the tabline";
      #   type = luaInline;
      #   default = mkLuaInline ''
      #     {
      #       {
      #         text = ' ',
      #         bg = vim.api.nvim_get_hl_by_name('Normal', true).background,
      #       },
      #       {
      #         text = '',
      #         fg = vim.api.nvim_get_hl_by_name('ColorColumn', true).background,
      #         bg = vim.api.nvim_get_hl_by_name('Normal', true).background,
      #       },
      #       {
      #         text = function(buffer)
      #           return buffer.devicon.icon
      #         end,
      #         fg = function(buffer)
      #           return buffer.devicon.color
      #         end,
      #       },
      #       {
      #         text = ' ',
      #       },
      #       {
      #         text = function(buffer) return buffer.filename .. '  ' end,
      #         style = function(buffer)
      #           return buffer.is_focused and 'bold' or nil
      #         end,
      #       },
      #       {
      #         text = '',
      #         delete_buffer_on_left_click = true,
      #       },
      #       {
      #         text = '',
      #         fg = vim.api.nvim_get_hl_by_name('ColorColumn', true).background,
      #         bg = vim.api.nvim_get_hl_by_name('Normal', true).background,
      #       }
      #     }
      #   '';
      # };
    };
  };
}
