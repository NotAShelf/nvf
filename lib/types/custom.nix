{lib}: let
  inherit (lib.options) mergeEqualOption;
  inherit (lib.strings) isString stringLength match;
  inherit (lib.types) listOf mkOptionType;
in {
  mergelessListOf = elemType:
    mkOptionType {
      name = "mergelessListOf";
      description = "mergeless list of ${elemType.description or "values"}";
      inherit (lib.types.listOf elemType) check;
      merge = mergeEqualOption;
    };

  char = mkOptionType {
    name = "char";
    description = "character";
    descriptionClass = "noun";
    check = value: stringLength value < 2;
    merge = mergeEqualOption;
  };

  hexColor = mkOptionType {
    name = "hex-color";
    descriptionClass = "noun";
    description = "RGB color in hex format";
    check = v: isString v && (match "#?[0-9a-fA-F]{6}" v) != null;
  };
}
