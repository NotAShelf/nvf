{lib}: let
  inherit (lib.options) mkOption;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.types) nullOr str;
  inherit (lib.attrsets) isAttrs mapAttrs;

  mkLuaBinding = mode: key: action: desc:
    mkIf (key != null) {
      ${key} = {
        inherit mode action desc;
        lua = true;
        silent = true;
      };
    };

  mkExprBinding = mode: key: action: desc:
    mkIf (key != null) {
      ${key} = {
        inherit mode action desc;
        lua = true;
        silent = true;
        expr = true;
      };
    };

  mkBinding = mode: key: action: desc:
    mkIf (key != null) {
      ${key} = {
        inherit mode action desc;
        silent = true;
      };
    };

  mkMappingOption = description: default:
    mkOption {
      type = nullOr str;
      inherit default description;
    };

  # Utility function that takes two attrsets:
  # { someKey = "some_value" } and
  # { someKey = { description = "Some Description"; }; }
  # and merges them into
  # { someKey = { value = "some_value"; description = "Some Description"; }; }
  addDescriptionsToMappings = actualMappings: mappingDefinitions:
    mapAttrs (name: value: let
      isNested = isAttrs value;
      returnedValue =
        if isNested
        then addDescriptionsToMappings actualMappings.${name} mappingDefinitions.${name}
        else {
          inherit value;
          inherit (mappingDefinitions.${name}) description;
        };
    in
      returnedValue)
    actualMappings;

  mkSetBinding = mode: binding: action:
    mkBinding mode binding.value action binding.description;

  mkSetExprBinding = mode: binding: action:
    mkExprBinding mode binding.value action binding.description;

  mkSetLuaBinding = mode: binding: action:
    mkLuaBinding mode binding.value action binding.description;

  pushDownDefault = attr: mapAttrs (_: mkDefault) attr;
in {
  inherit mkLuaBinding mkExprBinding mkBinding mkMappingOption addDescriptionsToMappings mkSetBinding mkSetExprBinding mkSetLuaBinding pushDownDefault;
}
