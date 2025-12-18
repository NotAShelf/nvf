{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit
    (lib.types)
    anything
    attrsOf
    listOf
    enum
    ;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
  inherit (lib.generators) mkLuaInline;
in {
  options.vim.utility.ccc = {
    enable = mkEnableOption "ccc color picker for neovim";

    setupOpts = mkPluginSetupOption "ccc.nvim" {
      highlighter = mkOption {
        type = attrsOf anything;
        default = {
          auto_enable = true;
          max_byte = 2 * 1024 * 1024; # 2mb
          lsp = true;
          filetypes = mkLuaInline "colorPickerFts";
        };
        description = ''
          Settings for the highlighter. See {command}`:help ccc` for options.
        '';
      };

      pickers = mkOption {
        type = listOf luaInline;
        default = map mkLuaInline [
          "ccc.picker.hex"
          "ccc.picker.css_rgb"
          "ccc.picker.css_hsl"
          "ccc.picker.ansi_escape { meaning1 = \"bold\", }"
        ];
        description = ''
          List of formats that can be detected by {command}`:CccPick` to be
          activated.

          Must be inline lua references to `ccc.picker`, for example
          `mkLuaInline "ccc.picker.hex"`. See {command}`:help ccc` for options.
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
        type = attrsOf anything;
        default = {
          output = true;
        };
        description = ''
          Settings for recognizing the color format. See {command}`:help ccc` for options.
        '';
      };

      inputs = mkOption {
        type = listOf luaInline;
        default = map mkLuaInline ["ccc.input.hsl"];
        description = ''
          List of color systems to be activated. Must be inline lua references to
          `ccc.input`, for example `mkLuaInline "ccc.input.rgb"`. See
          {command}`:help ccc` for options.

          The toggle input mode action toggles in this order. The first one is
          the default used at the first startup. Once activated, it will keep the
          previous input mode.
        '';
      };

      outputs = mkOption {
        type = listOf luaInline;
        default = map mkLuaInline [
          "ccc.output.css_hsl"
          "ccc.output.css_rgb"
          "ccc.output.hex"
        ];
        description = ''
          List of output formats to be activated. Must be inline Lua references to
          `ccc.output`, for example `mkLuaInline "ccc.output.rgb"`. See
          {command}`:help ccc` for options.

          The toggle output mode action toggles in this order. The first one is
          the default used at the first startup. Once activated, it will keep the
          previous output mode.
        '';
      };

      convert = mkOption {
        type = listOf (listOf luaInline);
        default = map (map mkLuaInline) [
          [
            "ccc.picker.hex"
            "ccc.output.css_hsl"
          ]
          [
            "ccc.picker.css_rgb"
            "ccc.output.css_hsl"
          ]
          [
            "ccc.picker.css_hsl"
            "ccc.output.hex"
          ]
        ];
        description = ''
          Specify the correspondence between picker and output. Must be a list of
          two-element lists defining picker/output pairs as inline Lua references,
          for example:

          ```nix
          map (map mkLuaInline) [
            ["ccc.picker.hex", "ccc.output.css_rgb"]
            ["ccc.picker.css_rgb", "ccc.output.hex"]
          ];
          ```

          See {command}`:help ccc` for options.
        '';
      };

      mappings = mkOption {
        type = attrsOf luaInline;
        default = {
          "q" = mkLuaInline "ccc.mapping.quit";
          "L" = mkLuaInline "ccc.mapping.increase10";
          "H" = mkLuaInline "ccc.mapping.decrease10";
        };
        description = ''
          The mappings are set in the UI of ccc. The table where lhs is key and
          rhs is value. To disable all default mappings, use
          {option}`vim.utility.ccc.setupOpts.disable_default_mappings`. To
          disable only some of the default mappings, set `ccc.mapping.none`.
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
