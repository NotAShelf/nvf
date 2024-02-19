{lib}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) bool;
in {
  # mkBoolOption: bool -> string -> option
  # e.g. mkBoolOption true "Enable feature X"
  mkBoolOption = value: description:
    mkOption {
      type = bool;
      default = value;
      inherit description;
    };
}
