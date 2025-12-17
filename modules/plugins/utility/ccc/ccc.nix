{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) listOf enum;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
  inherit (lib.generators) mkLuaInline;
in {
  options.vim.utility.ccc = {
    enable = mkEnableOption "ccc color picker for neovim";

    setupOpts = mkPluginSetupOption "ccc.nvim" {
      highlighter = mkOption {
        type = luaInline;
        default = mkLuaInline ''
          {
            auto_enable = true,
            max_byte = 2 * 1024 * 1024, -- 2mb
            lsp = true,
            filetypes = colorPickerFts,
          }
        '';
        description = "Settings for the highlighter";
      };

      pickers = mkOption {
        type = luaInline;
        default = mkLuaInline ''
          {
            ccc.picker.hex,
            ccc.picker.css_rgb,
            ccc.picker.css_hsl,
            ccc.picker.ansi_escape {
              meaning1 = "bright", -- whether the 1 means bright or yellow
            },
          }
        '';
        description = ''
          List of formats that can be detected by |:CccPick| to be activated.
        '';
      };

      alpha_show = mkOption {
        type = enum [
          "show"
          "hide"
          "auto"
        ];
        default = "hide";
        description = ''
          This option determines whether the alpha slider is displayed when the
          UI is opened. "show" and "hide" mean as they are. "auto" makes the
          slider appear only when the alpha value can be picked up.
        '';
      };

      recognize = mkOption {
        type = luaInline;
        default = mkLuaInline ''
          { output = true }
        '';
        description = "Settings for recognizing the color format.";
      };

      inputs = mkOption {
        type = listOf (enum [
          "rgb"
          "hsl"
          "hwb"
          "lab"
          "lch"
          "oklab"
          "oklch"
          "cmyk"
          "hsluv"
          "okhsl"
          "hsv"
          "okhsv"
          "xyz"
        ]);
        default = [
          "hsl"
        ];
        description = ''
          List of color systems to be activated.

          The toggle input mode action toggles in this order. The first one is
          the default used at the first startup. Once activated, it will keep the
          previous input mode.
        '';
      };

      outputs = mkOption {
        type = listOf (enum [
          "hex"
          "hex_short"
          "css_hsl"
          "css_rgb"
          "css_rgba"
          "css_hwb"
          "css_lab"
          "css_lch"
          "css_oklab"
          "css_oklch"
          "float"
        ]);
        default = [
          "css_hsl"
          "css_rgb"
          "hex"
        ];
        description = ''
          List of output formats to be activated.

          The toggle output mode action toggles in this order. The first one is
          the default used at the first startup. Once activated, it will keep the
          previous output mode.
        '';
      };

      convert = mkOption {
        type = luaInline;
        default = mkLuaInline ''
          {
            { ccc.picker.hex, ccc.output.css_hsl },
            { ccc.picker.css_rgb, ccc.output.css_hsl },
            { ccc.picker.css_hsl, ccc.output.hex },
          }
        '';
        description = ''
          Specify the correspondence between picker and output.
        '';
      };

      mappings = mkOption {
        type = luaInline;
        default = mkLuaInline ''
          {
            ["q"] = ccc.mapping.quit,
            ["L"] = ccc.mapping.increase10,
            ["H"] = ccc.mapping.decrease10,
          }
        '';
        description = ''
          The mappings are set in the UI of ccc. The table where lhs is key and
          rhs is value. To disable all default mappings, use
          disable_default_mappings. To disable only some of the default
          mappings, set ccc.mapping.none.
        '';
      };
    };

    mappings = {
      quit = mkMappingOption "Cancel and close the UI without replace or insert" "<Esc>";
      increase10 = mkMappingOption "Increase the value times delta of the slider" "<L>";
      decrease10 = mkMappingOption "Decrease the value times delta of the slider" "<H>";
    };
  };
}
