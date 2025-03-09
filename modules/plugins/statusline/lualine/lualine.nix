{
  config,
  lib,
  ...
}: let
  inherit (builtins) elem;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) int bool str listOf enum;
  inherit (lib.lists) optional;
  inherit (lib.nvim.types) mkPluginSetupOption;

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

    disabledFiletypes = mkOption {
      type = listOf str;
      description = "Filetypes to disable lualine on";
      default = ["alpha"];
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
        # TODO: xml generation error if the closing '' is on a new line.
        # issue: https://gitlab.com/rycee/nmd/-/issues/10
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
                local buf_ft = vim.api.nvim_get_option_value('filetype', {})

                -- List of buffer types to exclude
                local excluded_buf_ft = {"toggleterm", "NvimTree", "neo-tree", "TelescopePrompt"}

                -- Check if the current buffer type is in the excluded list
                for _, excluded_type in ipairs(excluded_buf_ft) do
                  if buf_ft == excluded_type then
                    return ""
                  end
                end

                -- Get the name of the LSP server active in the current buffer
                local clients = vim.lsp.get_active_clients()
                local msg = 'No Active Lsp'

                -- if no lsp client is attached then return the msg
                if next(clients) == nil then
                  return msg
                end

                for _, client in ipairs(clients) do
                  local filetypes = client.config.filetypes
                  if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                    return client.name
                  end
                end

                return msg
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
  };
}
