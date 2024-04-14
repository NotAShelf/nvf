{lib}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) bool;
in {
  mkBool = value: description:
    mkOption {
      type = bool;
      default = value;
      inherit description;
    };
}
