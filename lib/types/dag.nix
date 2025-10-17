# From home-manager: https://github.com/nix-community/home-manager/blob/master/modules/lib/types-dag.nix
# Used for ordering configuration text.
{lib, ...}: let
  # TODO: inherit from subgroups
  inherit
    (lib)
    defaultFunctor
    nvim
    mkIf
    mkOrder
    mkOption
    mkOptionType
    types
    ;

  dagEntryOf = elemType: let
    submoduleType = types.submodule ({name, ...}: {
      options = {
        data = mkOption {type = elemType;};
        after = mkOption {type = with types; listOf str;};
        before = mkOption {type = with types; listOf str;};
      };
      config = mkIf (elemType.name == "submodule") {
        data._module.args.dagName = name;
      };
    });
    maybeConvert = def:
      if nvim.dag.isEntry def.value
      then def.value
      else
        nvim.dag.entryAnywhere (
          if def ? priority
          then mkOrder def.priority def.value
          else def.value
        );
  in
    mkOptionType {
      name = "dagEntryOf";
      description = "DAG entry of ${elemType.description}";
      # leave the checking to the submodule type
      merge = loc: defs:
        submoduleType.merge loc (map (def: {
            inherit (def) file;
            value = maybeConvert def;
          })
          defs);
    };
in rec {
  # A directed acyclic graph of some inner type.
  #
  # Note, if the element type is a submodule then the `name` argument
  # will always be set to the string "data" since it picks up the
  # internal structure of the DAG values. To give access to the
  # "actual" attribute name a new submodule argument is provided with
  # the name `dagName`.
  dagOf = elemType: let
    attrEquivalent = types.attrsOf (dagEntryOf elemType);
  in
    mkOptionType rec {
      name = "dagOf";
      description = "DAG of ${elemType.description}";
      inherit (attrEquivalent) check merge emptyValue;
      inherit (elemType) getSubModules;
      getSubOptions = prefix: elemType.getSubOptions (prefix ++ ["<name>"]);
      substSubModules = m: dagOf (elemType.substSubModules m);
      functor = (defaultFunctor name) // {wrapped = elemType;};
      nestedTypes.elemType = elemType;
    };
}
