{lib}: let
  inherit (lib) isStringLike showOption showFiles getFiles mergeOneOption mergeEqualOption;
  inherit (lib.types) anything attrsOf;
  inherit (lib.nvim.types) anythingConcatLists;
  inherit (builtins) isAttrs foldl' head concatLists;
in {
  # A modified version of the nixpkgs anything type that concatenates lists
  # This isn't the default because the order in which the lists are concatenated depends on the order in which the modules are imported,
  # which makes it non-deterministic
  # HACK: Does this break anything in our case?
  anythingConcatLists =
    anything
    // {
      merge = loc: defs: let
        getType = value:
          if isAttrs value && isStringLike value
          then "stringCoercibleSet"
          else builtins.typeOf value;

        # Returns the common type of all definitions, throws an error if they
        # don't have the same type
        commonType =
          foldl' (
            type: def:
              if getType def.value == type
              then type
              else throw "The option `${showOption loc}' has conflicting option types in ${showFiles (getFiles defs)}"
          ) (getType (head defs).value)
          defs;

        mergeFunction =
          {
            # Recursively merge attribute sets
            set = (attrsOf anythingConcatLists).merge;
            # Overridden behavior for lists
            list = _: defs: concatLists (map (e: e.value) defs);
            # This is the type of packages, only accept a single definition
            stringCoercibleSet = mergeOneOption;
            lambda = loc: defs: arg:
              anythingConcatLists.merge
              (loc ++ ["<function body>"])
              (map (def: {
                  inherit (def) file;
                  value = def.value arg;
                })
                defs);
            # Otherwise fall back to only allowing all equal definitions
          }
          .${commonType}
          or mergeEqualOption;
      in
        mergeFunction loc defs;
    };
}
