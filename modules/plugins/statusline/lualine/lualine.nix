{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) int bool str listOf enum nullOr anything;
  inherit (lib.nvim.types) mkPluginSetupOption borderType;
  inherit (lib.generators) mkLuaInline;
  inherit (config.vim.lib) mkMappingOption;
in {
  options.vim.statusline.lualine = {
    enable = mkEnableOption "lualine statusline plugin";
    setupOpts = mkPluginSetupOption "Lualine" {
      sections = {
        lualine_a = mkOption {
          type = listOf anything;
          description = "active config for: | (A) | B | C       X | Y | Z |";
          default = [
            {
              "@1" = "mode";
              icons_enabled = true;
              separator = {
                left = "▎";
                right = "";
              };
            }
            {
              "@1" = "";
              draw_empty = true;
              separator = {
                left = "";
                right = "";
              };
            }
          ];
        };
        lualine_b = mkOption {
          type = listOf anything;
          description = "active config for: | A | (B) | C       X | Y | Z |";
          default = [
            {
              "@1" = "filetype";
              colored = true;
              icon_only = true;
              icon = {align = "left";};
            }
            {
              "@1" = "filename";
              symbols = {
                modified = " ";
                readonly = " ";
              };
              separator = {right = "";};
            }
            {
              "@1" = "";
              draw_empty = true;
              separator = {
                left = "";
                right = "";
              };
            }
          ];
        };
        lualine_c = mkOption {
          type = listOf anything;
          description = "active config for: | A | B | (C)       X | Y | Z |";
          default = [
            {
              "@1" = "diff";
              colored = false;
              diff_color = {
                added = "DiffAdd";
                modified = "DiffChange";
                removed = "DiffDelete";
              };
              symbols = {
                added = "+";
                modified = "~";
                removed = "-";
              };
              separator = {right = "";};
            }
          ];
        };
        lualine_x = mkOption {
          type = listOf anything;
          description = "active config for: | A | B | C       (X) | Y | Z |";
          default = [
            (mkLuaInline ''
              {
                -- Lsp server name
                function()
                  local buf_ft = vim.bo.filetype
                  local excluded_buf_ft = { toggleterm = true, NvimTree = true, ["neo-tree"] = true, TelescopePrompt = true }

                  if excluded_buf_ft[buf_ft] then
                    return ""
                    end

                  local bufnr = vim.api.nvim_get_current_buf()
                  local clients = vim.lsp.get_clients({ bufnr = bufnr })

                  if vim.tbl_isempty(clients) then
                    return "No Active LSP"
                  end

                  local active_clients = {}
                  for _, client in ipairs(clients) do
                    table.insert(active_clients, client.name)
                  end

                  return table.concat(active_clients, ", ")
                end,
                icon = " ",
                separator = {left = ""},
              }
            '')
            {
              "@1" = "diagnostics";
              sources = ["nvim_lsp" "nvim_diagnostic" "vim_lsp" "coc"];
              symbols = {
                error = "󰅙  ";
                warn = "  ";
                info = "  ";
                hint = "󰌵 ";
              };
              colored = true;
              update_in_insert = false;
              always_visible = false;
              diagnostics_color = {
                color_error = {fg = "red";};
                color_warn = {fg = "yellow";};
                color_info = {fg = "cyan";};
              };
            }
          ];
        };
        lualine_y = mkOption {
          type = listOf anything;
          description = "active config for: | A | B | C       X | (Y) | Z |";
          default = [
            {
              "@1" = "";
              draw_empty = true;
              separator = {
                left = "";
                right = "";
              };
            }
            {
              "@1" = "t";
              maxcount = 999;
              timeout = 120;
              separator = {left = "";};
            }
            {
              "@1" = "branch";
              icon = "•";
              separator = {left = "";};
            }
          ];
        };
        lualine_z = mkOption {
          type = listOf anything;
          description = "active config for: | A | B | C       X | Y | (Z) |";
          default = [
            {
              "@1" = "";
              draw_empty = true;
              separator = {
                left = "";
                right = "";
              };
            }
            {
              "@1" = "progress";
              separator = {left = "";};
            }
            ["location"]
            {
              "@1" = "fileformat";
              color = {fg = "black";};
              symbols = {
                unix = "";
                dos = "";
                mac = "";
              };
            }
          ];
        };
      };

      inactive_sections = {
        lualine_a = mkOption {
          type = listOf anything;
          description = "inactive config for: | (A) | B | C       X | Y | Z |";
          default = [];
        };
        lualine_b = mkOption {
          type = listOf anything;
          description = "inactive config for: | A | (B) | C       X | Y | Z |";
          default = [];
        };
        lualine_c = mkOption {
          type = listOf anything;
          description = "inactive config for: | A | B | (C)       X | Y | Z |";
          default = ["filename"];
        };
        lualine_x = mkOption {
          type = listOf anything;
          description = "inactive config for: | A | B | C       (X) | Y | Z |";
          default = ["location"];
        };
        lualine_y = mkOption {
          type = listOf anything;
          description = "inactive config for: | A | B | C       X | (Y) | Z |";
          default = [];
        };
        lualine_z = mkOption {
          type = listOf anything;
          description = "inactive config for: | A | B | C       X | Y | (Z) |";
          default = [];
        };
      };
    };

    integrations = {
      breadcrumbs = {
        location = mkOption {
          type = enum ["statusline" "winbar"];
          apply = value:
            {
              statusline = "sections";
              winbar = "winbar";
            }."${value}";
          default = "statusline";
          description = ''
            Where the breadcrumbs should appear
          '';
        };
        section = mkOption {
          type = enum ["a" "b" "c" "x" "y" "z"];
          default = "c";
          description = ''
            Which lualine section to occupy for the breadcrumbs feature.
          '';
        };

        vanilla = {
          enable = mkEnableOption "vanilla breadcrumbs";
          separator = {
            symbol = mkOption {
              type = str;
              default = ".";
              description = "Symbol to use for each breadcrumb entry";
              example = " > ";
            };
            color = mkOption {
              type = str;
              default = "@keyword";
              description = "Color to use for each breadcrumb symbol";
            };
          };
        };

        nvim-navic = {
          enable = mkEnableOption "nvim-navic";
          alwaysRender = mkOption {
            type = bool;
            default = true;
            description = ''
              This will pass `draw_empty` to the `nvim_navic` winbar
              component, which causes the component to be drawn even
              if it's empty.
            '';
          };
        };

        navbuddy = let
          mkSimpleIconOption = default:
            mkOption {
              inherit default;
              type = str;
              description = "";
            };
        in {
          enable = mkEnableOption "navbuddy LSP helper UI. Enabling this option automatically loads and enables nvim-navic";
          mappings = {
            close = mkMappingOption "Close and return the cursor to its original location." "<esc>";
            nextSibling = mkMappingOption "Navigate to the next sibling node." "j";
            previousSibling = mkMappingOption "Navigate to the previous sibling node." "k";
            parent = mkMappingOption "Navigate to the parent node." "h";
            children = mkMappingOption "Navigate to the child node." "l";
            root = mkMappingOption "Navigate to the root node." "0";
            visualName = mkMappingOption "Select the name visually." "v";
            visualScope = mkMappingOption "Select the scope visually." "V";
            yankName = mkMappingOption "Yank the name to system clipboard." "y";
            yankScope = mkMappingOption "Yank the scope to system clipboard." "Y";
            insertName = mkMappingOption "Insert at the start of name." "i";
            insertScope = mkMappingOption "Insert at the start of scope." "I";
            appendName = mkMappingOption "Insert at the end of name." "a";
            appendScope = mkMappingOption "Insert at the end of scope." "A";
            rename = mkMappingOption "Rename the node." "r";
            delete = mkMappingOption "Delete the node." "d";
            foldCreate = mkMappingOption "Create a new fold of the node." "f";
            foldDelete = mkMappingOption "Delete the current fold of the node." "F";
            comment = mkMappingOption "Comment the node." "c";
            select = mkMappingOption "Goto the node." "<enter>";
            moveDown = mkMappingOption "Move the node down." "J";
            moveUp = mkMappingOption "Move the node up." "K";
            togglePreview = mkMappingOption "Toggle the preview." "s";
            vsplit = mkMappingOption "Open the node in a vertical split." "<C-v>";
            hsplit = mkMappingOption "Open the node in a horizontal split." "<C-s>";
            telescope = mkMappingOption "Start fuzzy finder at the current level." "t";
            help = mkMappingOption "Open the mappings help window." "g?";
          };

          setupOpts = mkPluginSetupOption "navbuddy" {
            useDefaultMappings = mkOption {
              type = bool;
              default = true;
              description = "Add the default Navbuddy keybindings in addition to the keybinding added by this module.";
            };

            window = {
              # size = {}
              # position = {}

              border = mkOption {
                type = borderType;
                default = config.vim.ui.borders.globalStyle;
                description = "The border style to use.";
              };

              scrolloff = mkOption {
                type = nullOr int;
                default = null;
                description = "The scrolloff value within a navbuddy window.";
              };

              sections = {
                # left section
                left = {
                  /*
                  size = mkOption {
                    type = nullOr (intBetween 0 100);
                    default = null;
                    description = "size of the left section of Navbuddy UI in percentage (0-100)";
                  };
                  */

                  border = mkOption {
                    type = borderType;
                    default = config.vim.ui.borders.globalStyle;
                    description = "The border style to use for the left section of the Navbuddy UI.";
                  };
                };

                # middle section
                mid = {
                  /*
                  size = {
                    type = nullOr (intBetween 0 100);
                    default = null;
                    description = "size of the left section of Navbuddy UI in percentage (0-100)";
                  };
                  */

                  border = mkOption {
                    type = borderType;
                    default = config.vim.ui.borders.globalStyle;
                    description = "The border style to use for the middle section of the Navbuddy UI.";
                  };
                };

                # right section
                # there is no size option for the right section, it fills the remaining space
                right = {
                  border = mkOption {
                    type = borderType;
                    default = config.vim.ui.borders.globalStyle;
                    description = "The border style to use for the right section of the Navbuddy UI.";
                  };

                  preview = mkOption {
                    type = enum ["leaf" "always" "never"];
                    default = "leaf";
                    description = "The display mode of the preview on the right section.";
                  };
                };
              };
            };

            node_markers = {
              enable = mkEnableOption "node markers";
              icons = {
                leaf = mkSimpleIconOption "  ";
                leaf_selected = mkSimpleIconOption " → ";
                branch = mkSimpleIconOption " ";
              };
            };

            lsp = {
              auto_attach = mkOption {
                type = bool;
                default = true;
                description = "Whether to attach to LSP server manually.";
              };

              preference = mkOption {
                type = nullOr (listOf str);
                default = null;
                description = "The preference list ranking LSP servers.";
              };
            };

            source_buffer = {
              followNode = mkOption {
                type = bool;
                default = true;
                description = "Whether to keep the current node in focus in the source buffer.";
              };

              highlight = mkOption {
                type = bool;
                default = true;
                description = "Whether to highlight the currently focused node in the source buffer.";
              };

              reorient = mkOption {
                type = enum ["smart" "top" "mid" "none"];
                default = "smart";
                description = "The mode for reorienting the source buffer after moving nodes.";
              };

              scrolloff = mkOption {
                type = nullOr int;
                default = null;
                description = "The scrolloff value in the source buffer when Navbuddy is open.";
              };
            };

            icons = {
              File = mkSimpleIconOption "󰈙 ";
              Module = mkSimpleIconOption " ";
              Namespace = mkSimpleIconOption "󰌗 ";
              Package = mkSimpleIconOption " ";
              Class = mkSimpleIconOption "󰌗 ";
              Property = mkSimpleIconOption " ";
              Field = mkSimpleIconOption " ";
              Constructor = mkSimpleIconOption " ";
              Enum = mkSimpleIconOption "󰕘";
              Interface = mkSimpleIconOption "󰕘";
              Function = mkSimpleIconOption "󰊕 ";
              Variable = mkSimpleIconOption "󰆧 ";
              Constant = mkSimpleIconOption "󰏿 ";
              String = mkSimpleIconOption " ";
              Number = mkSimpleIconOption "󰎠 ";
              Boolean = mkSimpleIconOption "◩ ";
              Array = mkSimpleIconOption "󰅪 ";
              Object = mkSimpleIconOption "󰅩 ";
              Method = mkSimpleIconOption "󰆧 ";
              Key = mkSimpleIconOption "󰌋 ";
              Null = mkSimpleIconOption "󰟢 ";
              EnumMember = mkSimpleIconOption "󰕘 ";
              Struct = mkSimpleIconOption "󰌗 ";
              Event = mkSimpleIconOption " ";
              Operator = mkSimpleIconOption "󰆕 ";
              TypeParameter = mkSimpleIconOption "󰊄 ";
            };
          };
        };

        lspsaga = {
          enable = mkEnableOption "lspsaga breadcrumbs";
        };
      };
    };
  };
}
