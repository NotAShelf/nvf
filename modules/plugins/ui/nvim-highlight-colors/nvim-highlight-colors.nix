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

      virtual_symbol_position = mkOption {
        type = enum ["inline" "eol" "eow"];
        default = "inline";
        example = "eol";
        description = ''
          Where to render the virtual symbol in
          relation to the color string.

          ::: {.note}
          Each render style works as follows:
            - 'inline' render virtual text inline,
              similar to the style of VSCode color
              hinting.

            - 'eol' render virtual text at the end
              of the line which the color string
              occurs (last column). Recommended to
              set `virtual_symbol_suffix` to an
              empty string when used.

            - 'eow' render virtual text at the end
              of the word where the color string
              occurs. Recommended to set
              `virtual_symbol_prefix` to a single
              space for padding and the suffix to
              an empty string for no padding.
          :::
        '';
      };
    };
  };
}
