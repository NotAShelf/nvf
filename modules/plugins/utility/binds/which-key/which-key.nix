{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) attrsOf nullOr str;
in {
  options.vim.binds.whichKey = {
    enable = mkEnableOption "which-key keybind helper menu";

    register = mkOption {
      description = "Register label for which-key keybind helper menu";
      type = attrsOf (nullOr str);
      default = {};
    };
  };
}
