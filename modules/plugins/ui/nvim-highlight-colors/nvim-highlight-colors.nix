{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) attrsOf enum nullOr submodule bool str;
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (lib.nvim.config) mkBool;
in {
  options.vim.ui.nvim-highlight-colors = {
    enable = mkEnableOption "color highlighting [nvim-highlight-colors.lua]";

    setupOpts = mkPluginSetupOption "nvim-highlight-colors" {
      render = mkOption {
        type = enum ["background" "foreground" "virtual"];
        default = "background";
        example = "virtual";
        description = ''
          Style to render color highlighting with.

          ::: {.note}
          Each render style works as follows:
            - 'background' sets the background
              highlight of the matched color string
              to the RGB color it describes.

            - 'foreground' sets the foreground
              highlight of the matched color string
              to the RGB color it describes.

            - 'virtual' displays the matched color
              with virtual text alongside the color
              string in the buffer. Virtual text can
              be configured to display the color in
              various ways, i.e custom virtual symbol
              (via `virtual_symbol`) positioning
              relative to string, suffix/prefix, etc.
          :::
        '';
      };

      virtual_symbol = mkOption {
        type = nullOr str;
        default = "■";
        example = "⬤";
        description = ''
          Symbol to display color with as virtual text.

          ::: {.note}
          Only applies when `render` is set to 'virtual'.
          :::
        '';
      };

      virtual_symbol_prefix = mkOption {
        type = nullOr str;
        default = "";
        description = ''
          String used as a prefix to the virtual_symbol
          For example, to add padding between the color
          string and the virtual symbol.

          ::: {.note}
          Only applies when `render` is set to 'virtual'.
          :::
        '';
      };

      virtual_symbol_suffix = mkOption {
        type = nullOr str;
        default = " ";
        description = ''
          String used as a suffix to the virtual_symbol
          For example, to add padding between the virtual
          symbol and other text in the buffer.

          ::: {.note}
          Only applies when `render` is set to 'virtual'.
          :::
        '';
      };

      enable_hex = mkBool true "Enable highlighting for hex color strings, i.e `#FFFFFF`.";
      enable_short_hex = mkBool true "Enable highlighting for shorthand hex color format, i.e `#FFF`.";
      enable_rgb = mkBool true "Enable highlighting for RGB color strings, i.e `rgb(0, 0, 0)` or `rgb(0 0 0)`.";
      enable_hsl = mkBool true "Enable highlighting for HSL color strings, i.e `hsl(150deg 30% 40%)`.";
      enable_ansi = mkBool true "Enable highlighting for HSL color strings, i.e `\033[0;34m`.";
      enable_hsl_without_function = mkBool true "Enable highlighting for bare HSL color strings, i.e `--foreground: 0 69% 69%;`.";
      enable_var_usage = mkBool true "Enable highlighting for CSS variables which reference colors, i.e `var(--testing-color)`.";
      enable_named_colors = mkBool true "Enable highlighting for named colors, i.e `green`.";
      enable_tailwind = mkBool false "Enable highlighting for tailwind color classes, i.e `bg-blue-500`.";
    };
  };
}
