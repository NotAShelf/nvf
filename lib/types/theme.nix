{lib}: let
  inherit (lib.strings) isString;
  inherit (lib.types) mkOptionType;
  inherit (builtins) match;
  # This was almost entirely taken from raf himself.
in {
  hexColorType = mkOptionType {
    name = "hex-color";
    descriptionClass = "noun";
    description = "RGB color in hex format";
    # Check to determine wether the provided color is base16-valid
    check = x: isString x && (match "#[0-9a-fA-F]{6}" x) != null;
  };
}
