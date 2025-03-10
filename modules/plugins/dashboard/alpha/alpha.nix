{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) listOf attrsOf anything nullOr enum;
in {
  options.vim.dashboard.alpha = {
    enable = mkEnableOption "fast and fully programmable greeter for neovim [alpha.nvim]";
    theme = mkOption {
      type = nullOr (enum ["dashboard" "startify" "theta"]);
      default = "dashboard";
      description = "Alpha default theme to use";
    };
    layout = mkOption {
      type = listOf (attrsOf anything);
      default = [];
      description = "Alpha dashboard layout";
    };
    opts = mkOption {
      type = attrsOf anything;
      default = {};
      description = "Optional global options";
    };
  };
}
