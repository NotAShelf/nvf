{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.vim.ui.colorizer = {
    enable = mkEnableOption "nvim-colorizer.lua for color highlighting";

    filetypes = mkOption {
      type = with types; attrsOf attrs;
      default = {
        css = {};
        scss = {};
      };
      description = "Filetypes to highlight on";
    };

    options = {
      rgb = mkOption {
        type = types.bool;
        default = true;
        description = "#RGB hex codes";
      };

      rrggbb = mkOption {
        type = types.bool;
        default = true;
        description = "#RRGGBB hex codes";
      };

      names = mkOption {
        type = types.bool;
        default = true;
        description = ''"Name" codes such as "Blue"'';
      };

      rgb_fn = mkOption {
        type = types.bool;
        default = false;
        description = "CSS rgb() and rgba() functions";
      };

      rrggbbaa = mkOption {
        type = types.bool;
        default = false;
        description = "#RRGGBBAA hex codes";
      };

      hsl_fn = mkOption {
        type = types.bool;
        default = false;
        description = "CSS hsl() and hsla() functions";
      };

      css = mkOption {
        type = types.bool;
        default = false;
        description = "Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB";
      };

      css_fn = mkOption {
        type = types.bool;
        default = false;
        description = "Enable all CSS *functions*: rgb_fn, hsl_fn";
      };

      mode = mkOption {
        type = types.enum ["foreground" "background"];
        default = "background";
        description = "Set the display mode";
      };

      tailwind = mkOption {
        type = types.bool;
        default = false;
        description = "Enable tailwind colors";
      };

      sass = mkOption {
        type = types.bool;
        default = false;
        description = "Enable sass colors";
      };

      alwaysUpdate = mkOption {
        type = types.bool;
        default = false;
        description = "Update color values even if buffer is not focused, like when using cmp_menu, cmp_docs";
      };
    };
  };
}
