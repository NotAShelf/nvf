{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) listOf enum;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  options.vim.utility.ccc = {
    enable = mkEnableOption "ccc color picker for neovim";

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

    mappings = {
      quit = mkMappingOption "Cancel and close the UI without replace or insert" "<Esc>";
      increase10 = mkMappingOption "Increase the value times delta of the slider" "<L>";
      decrease10 = mkMappingOption "Decrease the value times delta of the slider" "<H>";
    };
  };
}
