{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) attrsOf str;
in {
  options.vim.binds.whichKey = {
    enable = mkEnableOption "which-key keybind helper menu";

    register = mkOption {
      description = "Register label for which-key keybind helper menu";
      type = attrsOf str;
      default = {};
    };
  };
}
