{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) attrsOf attrs bool enum;
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "ui" "colorizer" "options"] ["vim" "ui" "colorizer" "setupOpts" "user_default_options"])
    (mkRenamedOptionModule ["vim" "ui" "colorizer" "filetypes"] ["vim" "ui" "colorizer" "setupOpts" "filetypes"])
  ];

  options.vim.ui.colorizer = {
    enable = mkEnableOption "color highlighting [nvim-colorizer.lua]";

    setupOpts = mkPluginSetupOption "nvim-colorizer" {
      filetypes = mkOption {
        type = attrsOf attrs;
        default = {
          css = {};
          scss = {};
        };
        description = "Filetypes to highlight on";
      };

      user_default_options = {
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

        css = mkOption {
          type = bool;
          default = false;
          description = "Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB";
        };

        css_fn = mkOption {
          type = bool;
          default = false;
          description = "Enable all CSS *functions*: rgb_fn, hsl_fn";
        };

        mode = mkOption {
          type = enum ["foreground" "background"];
          default = "background";
          description = "Set the display mode";
        };

        tailwind = mkOption {
          type = bool;
          default = false;
          description = "Enable tailwind colors";
        };

        sass = mkOption {
          type = bool;
          default = false;
          description = "Enable sass colors";
        };

        alwaysUpdate = mkOption {
          type = bool;
          default = false;
          description = "Update color values even if buffer is not focused, like when using cmp_menu, cmp_docs";
        };
      };
    };
  };
}
