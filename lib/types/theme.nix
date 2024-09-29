{lib}: let
  inherit (lib.strings) isString hasPrefix;
  inherit (lib.types) mkOptionType;
  inherit (builtins) stringLength;
  # This was almost entirely taken from raf himself.
in {
  hexColorType = mkOptionType {
    name = "hex-color";
    descriptionClass = "noun";
    description = "RGB color in hex format";
    check = x: isString x && hasPrefix "#" x && stringLength x == 7;
  };
}
