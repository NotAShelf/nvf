{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) attrsOf enum nullOr submodule bool;
  inherit (lib.modules) mkRenamedOptionModule;

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

      mode = mkOption {
        description = "Set the display mode";
        type = nullOr (enum ["foreground" "background"]);
        default = null;
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

    defaultOptions = mkOption {
      description = ''
        Default options that apply to all filetypes. Filetype specific settings from
        [filetypeSettings](#opt-vim.ui.colorizer.filetypeSettings) take precedence.
      '';
      default = {};
      type = settingSubmodule;
    };

    filetypeOptions = mkOption {
      description = "Filetype specific settings";
      default = {};
      type = submodule {
        freeformType = attrsOf settingSubmodule;
      };
    };
  };
}
