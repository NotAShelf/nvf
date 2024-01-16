{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types attrNames mkIf nvim;

  cfg = config.vim.theme;
  supported_themes = import ./supported_themes.nix {inherit lib;};
in {
  options.vim.theme = {
    enable = mkOption {
      type = types.bool;
      description = "Enable theming";
    };

    name = mkOption {
      type = types.enum (attrNames supported_themes);
      description = "Supported themes can be found in `supported_themes.nix`";
    };

    style = mkOption {
      type = with types; enum supported_themes.${cfg.name}.styles;
      description = "Specific style for theme if it supports it";
    };

    transparent = mkOption {
      type = with types; bool;
      default = false;
      description = "Whether or not transparency should be enabled. Has no effect for themes that do not support transparency";
    };

    extraConfig = mkOption {
      type = with types; lines;
      description = "Additional lua configuration to add before setup";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [cfg.name];
    vim.luaConfigRC.themeSetup = nvim.dag.entryBefore ["theme"] cfg.extraConfig;
    vim.luaConfigRC.theme = supported_themes.${cfg.name}.setup (with cfg; {
      inherit style transparent;
    });
  };
}
