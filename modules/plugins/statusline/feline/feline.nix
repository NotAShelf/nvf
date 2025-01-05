{
  config,
  lib,
  ...
}: let
  inherit (builtins) elem;
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) str listOf attrsOf anything either submodule;
  inherit (lib.lists) optional;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) mkPluginSetupOption;

  conditionalRenderers = {
    options = {
      filetypes = mkOption {
        type = listOf str;
        default = [
          "^NvimTree$"
          "^neo-tree$"
          "^startify$"
          "^fugitive$"
          "^fugitiveblame$"
          "^qf$"
          "^help$"
        ];

        description = "Filetypes in which to force render inactive statusline";
      };

      buftypes = mkOption {
        type = listOf str;
        default = ["^terminal$"];
        description = "Buffer types in which to force render inactive statusline";
      };

      bufnames = mkOption {
        type = listOf str;
        default = [];
        description = "Buffer names in which to force render inactive statusline";
      };
    };
  };
in {
  options.vim.statusline.feline-nvim = {
    enable = mkEnableOption "minimal, stylish and customizable statusline, statuscolumn, and winbar [feline.nvim]";
    setupOpts = mkPluginSetupOption "feline-nvim" {
      custom_providers = mkOption {
        type = attrsOf anything;
        default = {};
        example = literalExpression ''
          {
            window_number = mkLuaInline ''''
              function()
                return tostring(vim.api.nvim_win_get_number(0))
              end
            '''';
          }
        '';

        description = "User-defined feline provider functions";
      };

      theme = mkOption {
        type = either str (attrsOf str);
        default = {};
        example = {
          fg = "#fff";
          bg = "#111";
        };
        description = ''
          Either a string containing the color theme name or an attribute set of
          strings, containing the colors.

          The theme’s `fg` and `bg` values also represent the default foreground
          and background colors, respectively.
        '';
      };

      separators = mkOption {
        type = listOf str;
        default = [];
        example = ["slant_right_2"];
        description = ''
          A table containing custom Feline separator prests.

          :::{.warning}
          This option is not type-checked! Before setting this option, please take
          a look at {command}`:help feline-separator-preset` for a list of
          available separator presets.
          :::
        '';
      };

      force_inactive = mkOption {
        default = {};
        type = attrsOf (submodule conditionalRenderers);
        description = ''
          A table that determines which buffers should always have the inactive
          statusline, even when they are active.
        '';
      };

      disable = mkOption {
        default = {};
        type = attrsOf (submodule conditionalRenderers);
        description = ''
          A table that determines which buffers should always have the statusline
          disabled, even when they are active.
        '';
      };

      vi_mode_colors = mkOption {
        type = attrsOf str;
        default = {};
        description = ''
          Attribute set  containing colors associated with specific Vi modes.

          It can later be used to get the color associated with the current Vim
          mode using `require('feline.providers.vi_mode').get_mode_color()`.

          See `:help feline-vi-mode` for more details on vi mode.



        '';
      };
    };
  };
}
