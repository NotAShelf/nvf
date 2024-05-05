{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) attrsOf enum nullOr submodule;
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.nvim.config) mkBool;

  settingSubmodule = submodule {
    options = {
      RGB = mkBool true "Colorize #RGB hex codes";
      RRGGBB = mkBool true "Colorize #RRGGBB hex codes";
      names = mkBool true ''Colorize "Name" codes like Blue'';
      RRGGBBAA = mkBool false "Colorize #RRGGBBAA hex codes";
      rgb_fn = mkBool false "Colorize CSS rgb() and rgba() functions";
      hsl_fn = mkBool false "Colorize CSS hsl() and hsla() functions";
      css = mkBool false "Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB";
      css_fn = mkBool false "Enable all CSS *functions*: rgb_fn, hsl_fn";
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
