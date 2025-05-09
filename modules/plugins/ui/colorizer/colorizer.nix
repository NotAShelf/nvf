{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) attrsOf enum nullOr submodule bool str;
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.nvim.types) mkPluginSetupOption;

  settingSubmodule = submodule {
    options = {
      RGB = mkOption {
        description = "Colorize #RGB hex codes";
        default = null;
        type = nullOr bool;
      };

      RRGGBB = mkOption {
        description = "Colorize #RRGGBB hex codes";
        default = null;
        type = nullOr bool;
      };

      names = mkOption {
        description = ''Colorize "Name" codes like Blue'';
        default = null;
        type = nullOr bool;
      };

      RRGGBBAA = mkOption {
        description = "Colorize #RRGGBBAA hex codes";
        default = null;
        type = nullOr bool;
      };

      AARRGGBB = mkOption {
        description = "Colorize 0xAARRGGBB hex codes";
        default = null;
        type = nullOr bool;
      };

      rgb_fn = mkOption {
        description = "Colorize CSS rgb() and rgba() functions";
        default = null;
        type = nullOr bool;
      };

      hsl_fn = mkOption {
        description = "Colorize CSS hsl() and hsla() functions";
        default = null;
        type = nullOr bool;
      };

      css = mkOption {
        description = "Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB";
        default = null;
        type = nullOr bool;
      };

      css_fn = mkOption {
        description = "Enable all CSS *functions*: rgb_fn, hsl_fn";
        default = null;
        type = nullOr bool;
      };

      tailwind = mkOption {
        description = "Enable tailwind colors";
        default = null;
        type = nullOr bool;
      };

      sass = mkOption {
        description = "Enable sass colors";
        default = null;
        type = nullOr bool;
      };

      virtualtext = mkOption {
        description = "String to display as virtualtext";
        type = nullOr str;
        default = null;
      };

      mode = mkOption {
        description = "Set the display mode";
        type = nullOr (enum ["foreground" "background"]);
        default = null;
      };

      always_update = mkOption {
        description = "Update color values even if buffer is not focused. Example use: cmp_menu, cmp_docs";
        default = null;
        type = nullOr bool;
      };
    };
  };
in {
  imports = [
    (mkRenamedOptionModule ["vim" "ui" "colorizer" "options"] ["vim" "ui" "colorizer" "setupOpts" "defaultOptions"])
    (mkRenamedOptionModule ["vim" "ui" "colorizer" "filetypes"] ["vim" "ui" "colorizer" "setupOpts" "filetypes"])
  ];

  options.vim.ui.colorizer = {
    enable = mkEnableOption "color highlighting [nvim-colorizer.lua]";

    setupOpts = mkPluginSetupOption "colorizer" {
      filetypes = mkOption {
        type = attrsOf settingSubmodule;
        default = {};
        example = {
          "*" = {};
          "!vim" = {};
          javascript = {
            AARRGGBB = false;
          };
        };
        description = ''
          Filetypes to enable on and their option overrides.

          `"*"` means enable on all filetypes. Filetypes prefixed with `"!"` are disabled.
        '';
      };

      user_default_options = mkOption {
        type = settingSubmodule;
        default = {};
        description = ''
          `user_default_options` is the second parameter to nvim-colorizer's setup function.

          Anything set here is the inverse of the previous setup configuration.
        '';
      };
    };
  };
}
