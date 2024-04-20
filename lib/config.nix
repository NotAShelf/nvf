{lib}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) bool;
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists) flatten;
in {
  mkBool = value: description:
    mkOption {
      type = bool;
      default = value;
      inherit description;
    };

  /*
  Generates a list of mkRenamedOptionModule, from a mapping of the old name to
  the new name. Nested options can optionally supply a "_name" to indicate its
  new name.

  # Example

  ```nix
  batchRenameOptions ["nvimTree"] ["nvimTree" "setupOpts"] {
      disableNetrw = "disable_netrw";
      nestedOption = {
        _name = "nested_option";
        somethingElse = "something_else";
      };
  }
  ```

  The above code is equivalent to this:

  ```nix
  [
    (
      mkRenamedOptionModule
        ["nvimTree" "disableNetrw"]
        ["nvimTree" "setupOpts" "disable_netrw"]
    )
    (
      mkRenamedOptionModule
        ["nvimTree" "nestedOption" "somethingElse"]
        ["nvimTree" "setupOpts" "nested_option" "something_else"]
    )
  ]
  ```
  */
  batchRenameOptions = oldBasePath: newBasePath: mappings: let
    genSetupOptRenames = oldSubpath: newSubpath: table:
      mapAttrsToList (
        oldName: newNameOrAttr:
          if builtins.isAttrs newNameOrAttr
          then
            genSetupOptRenames (oldSubpath ++ [oldName]) (newSubpath
              ++ [newNameOrAttr._name or oldName])
            newNameOrAttr
          else
            mkRenamedOptionModule
            (oldBasePath ++ oldSubpath ++ [oldName])
            (newBasePath ++ newSubpath ++ [newNameOrAttr])
      )
      table;
  in
    flatten (genSetupOptRenames [] [] mappings);
}
