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
  supportedThemes = import ./supported-themes.nix {
    inherit lib config;
  };
in {
  options.vim.theme = {
    enable = mkOption {
      type = bool;
      description = "Enable theming";
    };

    name = mkOption {
      type = enum (attrNames supportedThemes);
      description = "Supported themes can be found in `supportedThemes.nix`";
    };

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
      startPlugins = [cfg.name];
      luaConfigRC.theme = entryBefore ["pluginConfigs"] ''
        ${cfg.extraConfig}
        ${supportedThemes.${cfg.name}.setup {inherit (cfg) style transparent;}}
      '';
    };
  };
}
