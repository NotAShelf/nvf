{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.vim.ui.borders = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "visible borders for most windows";
    };

    # TODO: make per-plugin borders configurable
  };
}
