{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.ui.colorizer = {
    enable = mkEnableOption "nvim-colorizer.lua for color highlighting";

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
        default = true;
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
    };
  };
}
