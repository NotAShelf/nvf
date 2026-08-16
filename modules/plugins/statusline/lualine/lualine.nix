{
  config,
  lib,
  ...
}: let
  inherit (builtins) elem;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) int bool str listOf enum nullOr;
  inherit (lib.lists) optional;
  inherit (lib.nvim.types) mkPluginSetupOption borderType;
  inherit (config.vim.lib) mkMappingOption;

  supported_themes = import ./supported_themes.nix;
  builtin_themes = [
    "auto"
    "16color"
    "ayu_dark"
    "ayu_light"
    "ayu_mirage"
    "ayu"
    "base16"
    "codedark"
    "dracula"
    "everforest"
    "github_dark"
    "github_light"
    "github_dark_dimmed"
    "github_dark_default"
    "github_light_default"
    "github_dark_high_contrast"
    "github_light_high_contrast"
    "github_dark_colorblind"
    "github_light_colorblind"
    "github_dark_tritanopia"
    "github_light_tritanopia"
    "gruvbox"
    "gruvbox_dark"
    "gruvbox_light"
    "gruvbox-material"
    "horizon"
    "iceberg_dark"
    "iceberg_light"
    "iceberg"
    "jellybeans"
    "material"
    "modus-vivendi"
    "molokai"
    "moonfly"
    "nightfly"
    "nord"
    "OceanicNext"
    "onedark"
    "onelight"
    "palenight"
    "papercolor_dark"
    "papercolor_light"
    "PaperColor"
    "powerline_dark"
    "powerline"
    "pywal"
    "seoul256"
    "solarized_dark"
    "solarized_light"
    "Tomorrow"
    "wombat"
  ];
in {
  options.vim.statusline.lualine = {
    enable = mkEnableOption "lualine statusline plugin";
    setupOpts = mkPluginSetupOption "Lualine" {};

    icons.enable = mkEnableOption "icons for lualine" // {default = true;};

    refresh = {
      statusline = mkOption {
        type = int;
        description = "Refresh rate for lualine";
        default = 1000;
      };

      tabline = mkOption {
        type = int;
        description = "Refresh rate for tabline";
        default = 1000;
      };

      winbar = mkOption {
        type = int;
        description = "Refresh rate for winbar";
        default = 1000;
      };
    };

    globalStatus = mkOption {
      type = bool;
      description = "Enable global status for lualine";
      default = true;
    };

    alwaysDivideMiddle = mkOption {
      type = bool;
      description = "Always divide middle section";
      default = true;
    };

    disabledFiletypes = {
      statusline = mkOption {
        type = listOf str;
        default = ["alpha"];
        description = "Filetypes to disable lualine on for statusline";
      };
      winbar = mkOption {
        type = listOf str;
        default = [];
        description = "Filetypes to disable lualine on for winbar";
      };
    };

    ignoreFocus = mkOption {
      type = listOf str;
      default = ["NvimTree"];
      description = ''
        If current filetype is in this list it'll always be drawn as inactive statusline
        and the last window will be drawn as active statusline.
      '';
    };

    theme = let
      themeSupported = elem config.vim.theme.name supported_themes;
      themesConcatted = builtin_themes ++ optional themeSupported config.vim.theme.name;
    in
      mkOption {
        type = enum themesConcatted;
        default = "auto";
        defaultText = ''`config.vim.theme.name` if theme supports lualine else "auto"'';
        description = "Theme for lualine";
      };

    sectionSeparator = {
      left = mkOption {
        type = str;
        description = "Section separator for left side";
        default = "";
      };

      right = mkOption {
        type = str;
        description = "Section separator for right side";
        default = "";
      };
    };

    componentSeparator = {
      left = mkOption {
        type = str;
        description = "Component separator for left side";
        default = "";
      };

      right = mkOption {
        type = str;
        description = "Component separator for right side";
        default = "";
      };
    };

    activeSection = {
      a = mkOption {
        type = listOf str;
        description = "active config for: | (A) | B | C       X | Y | Z |";
        default = [
          ''
            {
              "mode",
              icons_enabled = true,
              separator = {
                left = '▎',
                right = ''
              },
            }
          ''
          ''
            {
              "",
              draw_empty = true,
              separator = { left = '', right = '' }
            }
          ''
        ];
      };

      b = mkOption {
        type = listOf str;
        description = "active config for: | A | (B) | C       X | Y | Z |";
        default = [
          ''
            {
              "filetype",
              colored = true,
              icon_only = true,
              icon = { align = 'left' }
            }
          ''
          ''
            {
              "filename",
              symbols = {modified = ' ', readonly = ' '},
              separator = {right = ''}
            }
          ''
          ''
            {
              "",
              draw_empty = true,
              separator = { left = '', right = '' }
            }
          ''
        ];
      };

      c = mkOption {
        type = listOf str;
        description = "active config for: | A | B | (C)       X | Y | Z |";
        default = [
          ''
            {
              "diff",
              colored = false,
              diff_color = {
                -- Same color values as the general color option can be used here.
                added    = 'DiffAdd',    -- Changes the diff's added color
                modified = 'DiffChange', -- Changes the diff's modified color
                removed  = 'DiffDelete', -- Changes the diff's removed color you
              },
              symbols = {added = '+', modified = '~', removed = '-'}, -- Changes the diff symbols
              separator = {right = ''}
            }
          ''
        ];
      };

      x = mkOption {
        type = listOf str;
        description = "active config for: | A | B | C       (X) | Y | Z |";
        default = [
          ''
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
              icon = ' ',
              separator = {left = ''},
            }
          ''
          ''
            {
              "diagnostics",
              sources = {'nvim_lsp', 'nvim_diagnostic', 'nvim_diagnostic', 'vim_lsp', 'coc'},
              symbols = {error = '󰅙  ', warn = '  ', info = '  ', hint = '󰌵 '},
              colored = true,
              update_in_insert = false,
              always_visible = false,
              diagnostics_color = {
                color_error = { fg = 'red' },
                color_warn = { fg = 'yellow' },
                color_info = { fg = 'cyan' },
              },
            }
          ''
        ];
      };

      y = mkOption {
        type = listOf str;
        description = "active config for: | A | B | C       X | (Y) | Z |";
        default = [
          ''
            {
              "",
              draw_empty = true,
              separator = { left = '', right = '' }
            }
          ''
          ''
            {
              'searchcount',
              maxcount = 999,
              timeout = 120,
              separator = {left = ''}
            }
          ''
          ''
            {
              "branch",
              icon = ' •',
              separator = {left = ''}
            }
          ''
        ];
      };

      z = mkOption {
        type = listOf str;
        description = "active config for: | A | B | C       X | Y | (Z) |";
        default = [
          ''
            {
              "",
              draw_empty = true,
              separator = { left = '', right = '' }
            }
          ''
          ''
            {
              "progress",
              separator = {left = ''}
            }
          ''
          ''
            {"location"}
          ''
          ''
            {
              "fileformat",
              color = {fg='black'},
              symbols = {
                unix = '', -- e712
                dos = '',  -- e70f
                mac = '',  -- e711
              }
            }
          ''
        ];
      };
    };

    extraActiveSection = {
      a = mkOption {
        type = listOf str;
        description = "Extra entries for activeSection.a";
        default = [];
      };

      b = mkOption {
        type = listOf str;
        description = "Extra entries for activeSection.b";
        default = [];
      };

      c = mkOption {
        type = listOf str;
        description = "Extra entries for activeSection.c";
        default = [];
      };

      x = mkOption {
        type = listOf str;
        description = "Extra entries for activeSection.x";
        default = [];
      };

      y = mkOption {
        type = listOf str;
        description = "Extra entries for activeSection.y";
        default = [];
      };

      z = mkOption {
        type = listOf str;
        description = "Extra entries for activeSection.z";
        default = [];
      };
    };

    inactiveSection = {
      a = mkOption {
        type = listOf str;
        description = "inactive config for: | (A) | B | C       X | Y | Z |";
        default = [];
      };

      b = mkOption {
        type = listOf str;
        description = "inactive config for: | A | (B) | C       X | Y | Z |";
        default = [];
      };

      c = mkOption {
        type = listOf str;
        description = "inactive config for: | A | B | (C)       X | Y | Z |";
        default = ["'filename'"];
      };

      x = mkOption {
        type = listOf str;
        description = "inactive config for: | A | B | C       (X) | Y | Z |";
        default = ["'location'"];
      };

      y = mkOption {
        type = listOf str;
        description = "inactive config for: | A | B | C       X | (Y) | Z |";
        default = [];
      };

      z = mkOption {
        type = listOf str;
        description = "inactive config for: | A | B | C       X | Y | (Z) |";
        default = [];
      };
    };
    extraInactiveSection = {
      a = mkOption {
        type = listOf str;
        description = "Extra entries for inactiveSection.a";
        default = [];
      };

      b = mkOption {
        type = listOf str;
        description = "Extra entries for inactiveSection.b";
        default = [];
      };

      c = mkOption {
        type = listOf str;
        description = "Extra entries for inactiveSection.c";
        default = [];
      };

      x = mkOption {
        type = listOf str;
        description = "Extra entries for inactiveSection.x";
        default = [];
      };

      y = mkOption {
        type = listOf str;
        description = "Extra entries for inactiveSection.y";
        default = [];
      };

      z = mkOption {
        type = listOf str;
        description = "Extra entries for inactiveSection.z";
        default = [];
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
