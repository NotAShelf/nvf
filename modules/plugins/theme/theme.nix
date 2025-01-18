{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.attrsets) attrNames;
  inherit (lib.strings) elemAt;
  inherit (lib.types) bool lines enum;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryBefore;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.theme;
  supportedThemes = import ./supported-themes.nix {
    inherit lib config;
  };
in {
  options.vim.theme = {
    inherit (supportedThemes.${cfg.name}) setupOpts;

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
    style = mkOption {
      type = enum supportedThemes.${cfg.name}.styles;
      default = elemAt supportedThemes.${cfg.name}.styles 0;
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
    vim = let
      name' =
        if cfg.name == "base16"
        then "mini.base16"
        else cfg.name;
    in {
      startPlugins = [cfg.name];
      luaConfigRC.theme = entryBefore ["pluginConfigs"] ''
         ${cfg.extraConfig}

        ${
          if name' != "oxocarbon"
          then "require('${name'}').setup(${toLuaObject cfg.setupOpts})"
          else ""
        }

        ${supportedThemes.${cfg.name}.setup}
      '';
    };
  };
}
