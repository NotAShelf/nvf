{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) enum bool either nullOr str int listOf attrs;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
in {
  options.vim.tabline.nvimBufferline = {
    enable = mkEnableOption "neovim bufferline";

    mappings = {
      closeCurrent = mkMappingOption config.vim.enableNvfKeymaps "Close buffer" null;
      cycleNext = mkMappingOption config.vim.enableNvfKeymaps "Next buffer" "<leader>bn";
      cyclePrevious = mkMappingOption config.vim.enableNvfKeymaps "Previous buffer" "<leader>bp";
      pick = mkMappingOption config.vim.enableNvfKeymaps "Pick buffer" "<leader>bc";
      sortByExtension = mkMappingOption config.vim.enableNvfKeymaps "Sort buffers by extension" "<leader>bse";
      sortByDirectory = mkMappingOption config.vim.enableNvfKeymaps "Sort buffers by directory" "<leader>bsd";
      sortById = mkMappingOption config.vim.enableNvfKeymaps "Sort buffers by ID" "<leader>bsi";
      moveNext = mkMappingOption config.vim.enableNvfKeymaps "Move next buffer" "<leader>bmn";
      movePrevious = mkMappingOption config.vim.enableNvfKeymaps "Move previous buffer" "<leader>bmp";
    };

    setupOpts = mkPluginSetupOption "Bufferline-nvim" {
      highlights = mkOption {
        type = either attrs luaInline;
        default =
          if config.vim.theme.enable && config.vim.theme.name == "catppuccin"
          then
            mkLuaInline
            ''
              require("catppuccin.groups.integrations.bufferline").get()
            ''
          else {};
        description = ''
          Overrides the highlight groups of bufferline.

          See `:help bufferline-highlights`.
        '';
      };

      options = {
        mode = mkOption {
          type = enum ["tabs" "buffers"];
          default = "buffers";
          description = "Mode to use for bufferline";
        };

        style_preset = mkOption {
          type = enum ["default" "minimal" "no_bold" "no_italic"];
          default = "default";
          apply = value: mkLuaInline "require('bufferline').style_preset.${value}";
          description = "The base style of bufferline";
        };

        themable = mkOption {
          type = bool;
          default = true;
          description = ''
            Whether or not to allow highlight groups to be overridden.

            While false, bufferline.nvim sets highlights as default.
          '';
        };

        numbers = mkOption {
          type = either (enum ["none" "ordinal" "buffer_id" "both"]) luaInline;
          default = mkLuaInline ''
            function(opts)
              return string.format('%s·%s', opts.raise(opts.id), opts.lower(opts.ordinal))
            end
          '';
          description = "Whether or not to show buffer numbers";
        };

        close_command = mkOption {
          type = either str luaInline;
          default = mkLuaInline ''
            function(bufnum)
              require("bufdelete").bufdelete(bufnum, false)
            end
          '';
          description = "Command to run when closing a buffer";
        };

        right_mouse_command = mkOption {
          type = nullOr (either str luaInline);
          default = "vertical sbuffer %d";
          description = "Command to run when right clicking a buffer";
        };

        left_mouse_command = mkOption {
          type = nullOr (either str luaInline);
          default = "buffer %d";
          description = "Command to run when left clicking a buffer";
        };

        middle_mouse_command = mkOption {
          type = nullOr (either str luaInline);
          default = null;
          description = "Command to run when middle clicking a buffer";
        };

        indicator = {
          icon = mkOption {
            type = nullOr str;
            default = null;
            description = ''
              The indicator icon to use for the current buffer.

              ::: {.warning}
              This **must** be omitted while style is not `icon`
              :::
            '';
          };

          style = mkOption {
            type = enum ["icon" "underline" "none"];
            default = "underline";
            description = "Style for indicator";
          };
        };

        buffer_close_icon = mkOption {
          type = str;
          default = " 󰅖 ";
          description = "Icon for close button";
        };

        modified_icon = mkOption {
          type = str;
          default = "● ";
          description = "Icon for modified buffer";
        };

        close_icon = mkOption {
          type = str;
          default = "  ";
          description = "Icon for close button";
        };

        left_trunc_marker = mkOption {
          type = str;
          default = "";
          description = "Icon for left truncation";
        };

        right_trunc_marker = mkOption {
          type = str;
          default = "";
          description = "Icon for right truncation";
        };

        name_formatter = mkOption {
          type = nullOr luaInline;
          default = null;
          description = ''
            `name_formatter` can be used to change the buffer's label in the
            bufferline.

            ::: {.note}
            Some names can/will break the bufferline so use this at your
            discretion knowing that it has some limitations that will
            **NOT** be fixed.
            :::
          '';
        };

        max_name_length = mkOption {
          type = int;
          default = 18;
          description = "Max name length";
        };

        max_prefix_length = mkOption {
          type = int;
          default = 15;
          description = "Length of the prefix used when a buffer is de-duplicated";
        };

        truncate_names = mkOption {
          type = bool;
          default = true;
          description = "Truncate names";
        };

        tab_size = mkOption {
          type = int;
          default = 18;
          description = "The size of the tabs in bufferline";
        };

        diagnostics = mkOption {
          type = enum [false "nvim_lsp" "coc"];
          default = "nvim_lsp";
          description = "Diagnostics provider to be used in buffer LSP indicators";
        };

        diagnostics_update_in_insert = mkOption {
          type = bool;
          default = false;
          description = ''
            Whether to update diagnostics while in insert mode.

            Setting this to true has performance implications, but they may be
            negligible depending on your setup. Set it to true if you know what
            you are doing.
          '';
        };

        diagnostics_indicator = mkOption {
          type = nullOr luaInline;
          default = mkLuaInline ''
            function(count, level, diagnostics_dict, context)
              local s = " "
                for e, n in pairs(diagnostics_dict) do
                  local sym = e == "error" and "   "
                    or (e == "warning" and "   " or "  " )
                  s = s .. n .. sym
                end
              return s
            end
          '';

          description = ''
            Function to get the diagnostics indicator.
            The function should return a string to be used as the indicator.

            Can be set to nil to keep the buffer name highlight, but delete the
            highlighting.
          '';
        };

        custom_filter = mkOption {
          type = nullOr luaInline;
          default = null;
          example = literalExpression ''
            custom_filter = function(buf_number, buf_numbers)
              -- filter out filetypes you don't want to see
              if vim.bo[buf_number].filetype ~= "<i-dont-want-to-see-this>" then
                return true
              end
              -- filter out by buffer name
              if vim.fn.bufname(buf_number) ~= "<buffer-name-I-dont-want>" then
                  return true
              end
              -- filter out based on arbitrary rules
              -- e.g. filter out vim wiki buffer from tabline in your work repo
              if vim.fn.getcwd() == "<work-repo>" and vim.bo[buf_number].filetype ~= "wiki" then
                  return true
              end
              -- filter out by it's index number in list (don't show first buffer)
              if buf_numbers[1] ~= buf_number then
                  return true
              end
            end
          '';

          description = ''
            Custom filter function for filtering out buffers.

            ::: {.note}
            This will be called a lot, so you are encouraged to keep it as
            short and lightweight as possible unless you are fully aware
            of the performance implications.
            :::
          '';
        };

        offsets = mkOption {
          type = listOf attrs;
          default = map (filetype: {
            inherit filetype;
            text = "File Explorer";
            highlight = "Directory";
            separator = true;
          }) ["NvimTree" "neo-tree" "snacks_layout_box"];
          description = "The windows to offset bufferline above, see `:help bufferline-offset`";
        };

        color_icons = mkOption {
          type = bool;
          default = true;
          description = "Whether or not to add filetype icon highlights";
        };

        get_element_icon = mkOption {
          type = nullOr luaInline;
          default = null;
          example = literalExpression ''
            function(element)
              local custom_map = {my_thing_ft: {icon = "my_thing_icon", hl = "DevIconDefault"}}
              return custom_map[element.filetype]
            end
          '';
          description = "The function bufferline uses to get the icon. Recommended to leave as default.";
        };

        show_buffer_icons = mkOption {
          type = bool;
          default = true;
          description = "Whether or not to show buffer icons";
        };

        show_buffer_close_icons = mkOption {
          type = bool;
          default = true;
          description = "Whether or not to show buffer close icons";
        };

        show_close_icon = mkOption {
          type = bool;
          default = true;
          description = "Whether or not to show the close icon";
        };

        show_tab_indicators = mkOption {
          type = bool;
          default = true;
          description = "Whether or not to show tab indicators";
        };

        show_duplicate_prefix = mkOption {
          type = bool;
          default = true;
          description = "Whether or not to show duplicate buffer prefixes";
        };

        duplicates_across_groups = mkOption {
          type = bool;
          default = true;
          description = "Whether to consider duplicate paths in different groups as duplicates";
        };

        persist_buffer_sort = mkOption {
          type = bool;
          default = true;
          description = "Whether or not custom sorted buffers should persist";
        };

        move_wraps_at_ends = mkOption {
          type = bool;
          default = false;
          description = "Whether or not the move command \"wraps\" at the first or last position";
        };

        separator_style = mkOption {
          type = nullOr (either (enum ["slant" "padded_slant" "slope" "padded_slope" "thick" "thin"]) (listOf str));
          default = "thin";
          description = ''
            The type of separator used to separate buffers and tabs.

            Either one of the listed types, or a list of 2 characters for either side.
          '';
        };

        enforce_regular_tabs = mkOption {
          type = bool;
          default = false;
          description = "Whether to enforce regular tabs";
        };

        always_show_bufferline = mkOption {
          type = bool;
          default = true;
          description = "Whether to always show bufferline";
        };

        auto_toggle_bufferline = mkOption {
          type = bool;
          default = true;
          description = "Whether to auto toggle bufferline";
        };

        hover = {
          enabled = mkEnableOption "hover" // {default = true;};
          delay = mkOption {
            type = int;
            default = 200;
            description = "Delay for hover, in ms";
          };

          reveal = mkOption {
            type = listOf str;
            default = ["close"];
            description = "Reveal hover window";
          };
        };

        sort_by = mkOption {
          type = either (enum ["insert_after_current" "insert_at_end" "id" "extension" "relative_directory" "directory" "tabs"]) luaInline;
          default = "extension";
          description = "Method to sort buffers by. Must be one of the supported values, or an inline Lua value.";
        };
      };
    };
  };
}
