{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.lists) optionals;
  inherit (lib.types) enum;

  cfg = config.vim.ui.borders;

  defaultStyles = ["none" "single" "double" "rounded"];
in {
  options.vim.ui.borders = {
    enable = mkEnableOption "visible borders for most windows";

    globalStyle = mkOption {
      type = enum defaultStyles;
      default = "rounded";
      description = ''
        The global border style to use
      '';
    };

    # TODO: make per-plugin borders configurable
    plugins = let
      mkPluginStyleOption = name: {
        enable = mkEnableOption "borders for the ${name} plugin" // {default = cfg.enable;};

        style = mkOption {
          type = enum (defaultStyles ++ optionals (name != "which-key") ["shadow"]);
          default = cfg.globalStyle;
          description = "The border style to use for the ${name} plugin";
        };
      };
    in {
      # despite not having it listed in example configuration, which-key does support the rounded type
      # additionally, it supports a "shadow" type that is similar to none but is of higher contrast
      which-key = mkPluginStyleOption "which-key";
      lspsaga = mkPluginStyleOption "lspsaga";
      nvim-cmp = mkPluginStyleOption "nvim-cmp";
      lsp-signature = mkPluginStyleOption "lsp-signature";
      code-action-menu = mkPluginStyleOption "code-actions-menu";
    };
  };
}
