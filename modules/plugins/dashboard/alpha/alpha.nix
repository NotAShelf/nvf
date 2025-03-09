{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) listOf attrsOf anything nullOr enum;
in {
  options.vim.dashboard.alpha = {
    enable = mkEnableOption "fast and fully programmable greeter for neovim [alpha.nvim]";
    theme = mkOption {
      default = null;
      type = nullOr (enum ["dashboard" "startify" "theta"]);
      description = ''
        Alpha default theme to use.
      '';
    };
    layout = mkOption {
      default = [];
      type = listOf (attrsOf anything);
      description = ''
        Alpha dashboard layout.
      '';
    };
    opts = mkOption {
      default = {};
      type = attrsOf anything;
      description = ''
        Optional global options.
      '';
    };
  };
}
