{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.lists) optionals;
  inherit (lib.types) enum;

  cfg = config.vim.ui.borders;

  # See `:h nvim_open_win` for the available border styles
  # this list can be updated if additional styles are added.
  defaultStyles = ["none" "single" "double" "rounded" "solid" "shadow"];
in {
  options.vim.ui.borders = {
    enable = mkEnableOption "visible borders for windows that support configurable borders";

    # TODO: support configurable border elements with a lua table converted from a list of str
    # e.g. [ "╔" "═" "╗" "║" "╝" "═" "╚" "║" ]
    globalStyle = mkOption {
      type = enum defaultStyles;
      default = "single";
      description = ''
        The global border style to use.
      '';
    };

    plugins = let
      mkPluginStyleOption = name: {
        enable = mkEnableOption "borders for the ${name} plugin" // {default = cfg.enable;};

        style = mkOption {
          type = enum (defaultStyles ++ optionals (name != "which-key") ["shadow"]);
          default = cfg.globalStyle;
          description = "The border style to use for the ${name} plugin";
        };
      };
    in
      mapAttrs (_: mkPluginStyleOption) {
        # despite not having it listed in example configuration, which-key does support the rounded type
        # additionally, it supports a "shadow" type that is similar to none but is of higher contrast
        which-key = "which-key";
        lspsaga = "lspsaga";
        nvim-cmp = "nvim-cmp";
        lsp-signature = "lsp-signature";
        code-action-menu = "code-actions-menu";
      };
  };
}
