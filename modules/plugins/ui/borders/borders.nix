{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.nvim.types) borderType;

  cfg = config.vim.ui.borders;
in {
  options.vim.ui.borders = {
    enable = mkEnableOption "visible borders for most windows";

    globalStyle = mkOption {
      type = borderType;
      default = "rounded";
      description = ''
        The global border style to use.

        If a list is given, it should have a length of eight or any divisor of
        eight. The array will specify the eight chars building up the border in
        a clockwise fashion starting with the top-left corner. You can specify
        a different highlight group for each character by passing a
        [char, "YourHighlightGroup"] instead
      '';
      example = ["╔" "═" "╗" "║" "╝" "═" "╚" "║"];
    };

    plugins = let
      mkPluginStyleOption = name: {
        enable = mkEnableOption "borders for the ${name} plugin" // {default = cfg.enable;};

        style = mkOption {
          type = borderType;
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
      fastaction = mkPluginStyleOption "fastaction";
    };
  };
}
