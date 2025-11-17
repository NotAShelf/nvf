{lib}: let
  inherit (builtins) toJSON;
  inherit (lib.options) mergeEqualOption;
  inherit (lib.lists) singleton;
  inherit (lib.strings) isString stringLength match;
  inherit (lib.types) listOf mkOptionType coercedTo;
  inherit (lib.trivial) warn;
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

  # no compound types please
  deprecatedSingleOrListOf = option: t:
    coercedTo
    t
    (x:
      warn ''
        ${option} no longer accepts non-list values, use [${toJSON x}] instead
      ''
      (singleton x))
    (listOf t);
}
