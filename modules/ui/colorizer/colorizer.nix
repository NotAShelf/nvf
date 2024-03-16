{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) attrsOf attrs bool enum;
in {
  options.vim.ui.colorizer = {
    enable = mkEnableOption "color highlighting [nvim-colorizer.lua]";

    filetypes = mkOption {
      type = attrsOf attrs;
      default = {
        css = {};
        scss = {};
      };
      description = "Filetypes to highlight on";
    };

    options = {
      alwaysUpdate = mkEnableOption "updating color values even if buffer is not focused, like when using cmp_menu, cmp_docs";

      rgb = mkOption {
        type = bool;
        default = true;
        description = "#RGB hex codes";
      };

      rrggbb = mkOption {
        type = bool;
        default = true;
        description = "#RRGGBB hex codes";
      };

      names = mkOption {
        type = bool;
        default = true;
        description = ''"Name" codes such as "Blue"'';
      };

      rgb_fn = mkOption {
        type = bool;
        default = false;
        description = "CSS rgb() and rgba() functions";
      };

      rrggbbaa = mkOption {
        type = bool;
        default = false;
        description = "#RRGGBBAA hex codes";
      };

      hsl_fn = mkOption {
        type = bool;
        default = false;
        description = "CSS hsl() and hsla() functions";
      };

      mode = mkOption {
        type = enum ["foreground" "background"];
        default = "background";
        description = "Set the display mode";
      };

      tailwind = mkEnableOption "tailwind colors";
      sass = mkEnableOption "sass colors";
      css = mkEnableOption "all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB";
      css_fn = mkEnableOption "all CSS *functions*: rgb_fn, hsl_fn";
    };
  };
}
