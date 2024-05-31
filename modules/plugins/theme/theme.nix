{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.attrsets) attrNames;
  inherit (lib.types) bool lines enum;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryBefore;

  cfg = config.vim.theme;
  supported_themes = import ./supported_themes.nix {
    inherit lib config;
  };
in {
  options.vim.theme = {
    enable = mkOption {
      type = bool;
      description = "Enable theming";
    };

    name = mkOption {
      type = enum (attrNames supported_themes);
      description = "Supported themes can be found in `supported_themes.nix`";
    };

    style = mkOption {
      type = enum supported_themes.${cfg.name}.styles;
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
      startPlugins = [cfg.name];
      luaConfigRC = {
        themeSetup = entryBefore ["theme"] cfg.extraConfig;
        theme = supported_themes.${cfg.name}.setup (with cfg; {inherit style transparent;});
      };
    };
  };
}
