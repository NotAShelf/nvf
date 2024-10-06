{lib}: let
  inherit (lib.options) showOption showFiles getFiles mergeOneOption mergeEqualOption;
  inherit (lib.strings) isString isStringLike;
  inherit (lib.types) anything attrsOf listOf mkOptionType;
  inherit (lib.nvim.types) anythingConcatLists;
  inherit (builtins) typeOf isAttrs any head concatLists stringLength match;
in {
  # HACK: Does this break anything in our case?
  # A modified version of the nixpkgs anything type that concatenates lists
  # This isn't the default because the order in which the lists are concatenated depends on the order in which the modules are imported,
  # which makes it non-deterministic
  anythingConcatLists =
    anything
    // {
      merge = loc: defs: let
        getType = value:
          if isAttrs value && isStringLike value
          then "stringCoercibleSet"
          else typeOf value;

        # Throw an error if not all defs have the same type
        checkType = getType (head defs).value;
        commonType =
          if any (def: getType def.value != checkType) defs
          then throw "The option `${showOption loc}' has conflicting option types in ${showFiles (getFiles defs)}"
          else checkType;

        mergeFunctions = {
          # Recursively merge attribute sets
          set = (attrsOf anythingConcatLists).merge;

          # Overridden behavior for lists, that concatenates lists
          list = _: defs: concatLists (map (e: e.value) defs);

          # This means it's a package, only accept a single definition
          stringCoercibleSet = mergeOneOption;

          # This works by passing the argument to the functions,
          # and merging their returns values instead
          lambda = loc: defs: arg:
            anythingConcatLists.merge
            (loc ++ ["<function body>"])
            (map (def: {
                inherit (def) file;
                value = def.value arg;
              })
              defs);
        };
      in
        # Merge the defs with the correct function from above, if available
        # otherwise only allow equal values
        (mergeFunctions.${commonType} or mergeEqualOption) loc defs;
    };

  mergelessListOf = elemType: listOf elemType // {merge = mergeEqualOption;};

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
