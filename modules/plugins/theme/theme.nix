{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.attrsets) attrNames;
  inherit (lib.strings) hasPrefix;
  inherit (lib.types) bool lines enum;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.dag) entryBefore;
  inherit (lib.nvim.types) hexColor;

  cfg = config.vim.theme;
  supportedThemes = import ./supported-themes.nix {
    inherit lib config;
  };

  numbers = ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "A" "B" "C" "D" "E" "F"];
  base16Options =
    mapListToAttrs (n: {
      name = "base0${n}";
      value = mkOption {
        description = "The base0${n} color to use";
        type = hexColor;
        apply = v:
          if hasPrefix "#" v
          then v
          else "#${v}";
      };
    })
    numbers;
in {
  options.vim.theme = {
    enable = mkOption {
      type = bool;
      description = "Enable theming";
    };
    name = mkOption {
      type = enum (attrNames supportedThemes);
      description = ''
        Supported themes can be found in {file}`supportedThemes.nix`.
        Setting the theme to "base16" enables base16 theming and
        requires all of the colors in {option}`vim.theme.base16-colors` to be set.
      '';
    };
    base16-colors = base16Options;

    style = mkOption {
      type = enum supportedThemes.${cfg.name}.styles;
      description = "Specific style for theme if it supports it";
    };
    transparent = mkOption {
      type = bool;
      default = false;
      description = "Whether or not transparency should be enabled. Has no effect for themes that do not support transparency";
    };

    extraConfig = mkOption {
      type = lines;
      description = "Additional lua configuration to add before setup";
    };
  };

  config = mkIf cfg.enable {
    vim = {
      startPlugins =
        if (supportedThemes.${cfg.name} ? builtin) && supportedThemes.${cfg.name}.builtin
        then []
        else [cfg.name];
      luaConfigRC.theme = entryBefore ["pluginConfigs" "lazyConfigs"] ''
        ${cfg.extraConfig}
        ${supportedThemes.${cfg.name}.setup {inherit (cfg) style transparent base16-colors;}}
      '';
    };
  };
}
