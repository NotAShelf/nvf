{lib}: let
  inherit (builtins) toJSON attrNames;
  inherit (lib.options) mergeEqualOption;
  inherit (lib.lists) singleton;
  inherit (lib.strings) isString stringLength match;
  inherit (lib.types) listOf mkOptionType coercedTo enum;
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
  deprecatedSingleOrListOf = option: t: let
    targetType = listOf t;
  in
    (coercedTo
      t
      (x:
        warn ''
          ${option} no longer accepts non-list values, use [${toJSON x}] instead
        ''
        (singleton x))
      targetType)
    // {inherit (targetType) description descriptionClass;};

  # Create an enum type for `values`, which additionally accepts deprecated
  # values listed in the `renames` attrset as `old = new` pairs.
  #
  # Example:
  #
  # vim.languages.typescript.lsp.servers = mkOption {
  #   type = enumWithRename
  #     "vim.languages.typescript.lsp.servers"
  #     ["typescript-language-server" "some-other-server"]
  #     { ts_ls = "typescript-language-server"; };
  # }
  #
  # With this option definition, when users enter `ts_ls`, they
  # get a warning "`ts_ls` is deprecated, use `typescript-language-server`
  # instead", and typescript-language-server is automatically used.
  enumWithRename = option: values: renames: let
    targetType = enum values;
  in
    (coercedTo (enum (attrNames renames)) (
        old:
          warn
          "${option}: `${old}` is deprecated, use `${renames.${old}}` instead"
          renames.${old}
      )
      targetType)
    // {inherit (targetType) description descriptionClass;};
}
