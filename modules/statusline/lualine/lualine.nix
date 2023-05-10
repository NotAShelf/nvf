{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  supported_themes = import ./supported_themes.nix;
in {
  options.vim.statusline.lualine = {
    enable = mkEnableOption "lualine";

    icons = {
      enable = mkOption {
        type = types.bool;
        description = "Enable icons for lualine";
        default = true;
      };
    };

    refresh = {
      statusline = mkOption {
        type = types.int;
        description = "Refresh rate for lualine";
        default = 1000;
      };
      tabline = mkOption {
        type = types.int;
        description = "Refresh rate for tabline";
        default = 1000;
      };
      winbar = mkOption {
        type = types.int;
        description = "Refresh rate for winbar";
        default = 1000;
      };
    };

    globalStatus = mkOption {
      type = types.bool;
      description = "Enable global status for lualine";
      default = true;
    };

    theme = let
      themeSupported = elem config.vim.theme.name supported_themes;
    in
      mkOption {
        description = "Theme for lualine";
        type = types.enum ([
            "auto"
            "16color"
            "gruvbox"
            "ayu_dark"
            "ayu_light"
            "ayu_mirage"
            "codedark"
            "dracula"
            "everforest"
            "gruvbox"
            "gruvbox_light"
            "gruvbox_material"
            "horizon"
            "iceberg_dark"
            "iceberg_light"
            "jellybeans"
            "material"
            "modus_vivendi"
            "molokai"
            "nightfly"
            "nord"
            "oceanicnext"
            "onelight"
            "palenight"
            "papercolor_dark"
            "papercolor_light"
            "powerline"
            "seoul256"
            "solarized_dark"
            "tomorrow"
            "wombat"
          ]
          ++ optional themeSupported config.vim.theme.name);
        default = "auto";
        # TODO: xml generation error if the closing '' is on a new line.
        # issue: https://gitlab.com/rycee/nmd/-/issues/10
        defaultText = nvim.nmd.literalAsciiDoc ''`config.vim.theme.name` if theme supports lualine else "auto"'';
      };

    sectionSeparator = {
      left = mkOption {
        type = types.str;
        description = "Section separator for left side";
        default = "";
      };

      right = mkOption {
        type = types.str;
        description = "Section separator for right side";
        default = "";
      };
    };

    componentSeparator = {
      left = mkOption {
        type = types.str;
        description = "Component separator for left side";
        default = "";
      };

      right = mkOption {
        type = types.str;
        description = "Component separator for right side";
        default = "";
      };
    };

    activeSection = {
      a = mkOption {
        type = types.str;
        description = "active config for: | (A) | B | C       X | Y | Z |";
        default = ''
          {
            {
              "mode",
              separator = {
                left = '▎',
              },
            },
          }
        '';
      };

      b = mkOption {
        type = types.str;
        description = "active config for: | A | (B) | C       X | Y | Z |";
        default = ''
          {
            {
              "filetype",
              colored = true,
              icon_only = true,
              icon = { align = 'left' },
              color = {bg='none', fg='lavender'},
            },
            {
              "filename",
              color = {bg='none'},
              symbols = {modified = '', readonly = ''},
            },
          }
        '';
      };

      c = mkOption {
        type = types.str;
        description = "active config for: | A | B | (C)       X | Y | Z |";
        default = ''
          {
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
              color = {
                bg='none',
                fg='lavender'
              },
            },
          }
        '';
      };

      x = mkOption {
        type = types.str;
        description = "active config for: | A | B | C       (X) | Y | Z |";
        default = ''
          {
            {
              "diagnostics",
              sources = {'nvim_lsp', 'nvim_diagnostic', 'coc'},
              symbols = {error = '󰅙 ', warn = ' ', info = ' ', hint = '󰌵 '}
            },
          }
        '';
      };

      y = mkOption {
        type = types.str;
        description = "active config for: | A | B | C       X | (Y) | Z |";
        default = ''
          {
            {
              "fileformat",
              color = {bg='none', fg='lavender'},
              symbols = {
                unix = '', -- e712
                dos = '',  -- e70f
                mac = '',  -- e711
              },
            },
          }
        '';
      };

      z = mkOption {
        type = types.str;
        description = "active config for: | A | B | C       X | Y | (Z) |";
        default = ''
          {
            {
              "progress",
              color = {bg='none', fg='lavender'},
            },
            {
              "location",
              color = {bg='none', fg='lavender'},
            },
            {
              "branch",
              icon = ' •',
              separator = {
                left = '(',
                right = ')'
              },
              color = {bg='none', fg='lavender'},

            },
          }
        '';
      };
    };

    inactiveSection = {
      a = mkOption {
        type = types.str;
        description = "inactive config for: | (A) | B | C       X | Y | Z |";
        default = "{}";
      };

      b = mkOption {
        type = types.str;
        description = "inactive config for: | A | (B) | C       X | Y | Z |";
        default = "{}";
      };

      c = mkOption {
        type = types.str;
        description = "inactive config for: | A | B | (C)       X | Y | Z |";
        default = "{'filename'}";
      };

      x = mkOption {
        type = types.str;
        description = "inactive config for: | A | B | C       (X) | Y | Z |";
        default = "{'location'}";
      };

      y = mkOption {
        type = types.str;
        description = "inactive config for: | A | B | C       X | (Y) | Z |";
        default = "{}";
      };

      z = mkOption {
        type = types.str;
        description = "inactive config for: | A | B | C       X | Y | (Z) |";
        default = "{}";
      };
    };
  };
}
