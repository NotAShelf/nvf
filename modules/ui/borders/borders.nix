{lib, ...}: let
  inherit (lib) mkEnableOption mkOption;
in {
  options.vim.ui.borders = {
    enable = mkEnableOption "visible borders for most windows";

    # TODO: make per-plugin borders configurable
  };
}
