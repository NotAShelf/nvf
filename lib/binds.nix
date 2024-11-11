{lib}: let
  inherit (lib.options) mkOption;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.types) nullOr str;
  inherit (lib.attrsets) isAttrs mapAttrs;

  binds = rec {
    mkLuaBinding = key: action: desc:
      mkIf (key != null) {
        "${key}" = {
          inherit action desc;
          lua = true;
          silent = true;
        };
      };

    mkExprBinding = key: action: desc:
      mkIf (key != null) {
        "${key}" = {
          inherit action desc;
          lua = true;
          silent = true;
          expr = true;
        };
      };

    mkBinding = key: action: desc:
      mkIf (key != null) {
        "${key}" = {
          inherit action desc;
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
          then addDescriptionsToMappings actualMappings."${name}" mappingDefinitions."${name}"
          else {
            inherit value;
            inherit (mappingDefinitions."${name}") description;
          };
      in
        returnedValue)
      actualMappings;

    mkSetBinding = binding: action:
      mkBinding binding.value action binding.description;

    mkSetExprBinding = binding: action:
      mkExprBinding binding.value action binding.description;

    mkSetLuaBinding = binding: action:
      mkLuaBinding binding.value action binding.description;

    pushDownDefault = attr: mapAttrs (_: mkDefault) attr;

    mkLznBinding = mode: key: action: desc: {
      inherit mode desc key action;
    };

    mkLznExprBinding = mode: key: action: desc: {
      inherit mode desc key action;
      lua = true;
      silent = true;
      expr = true;
    };

    mkSetLznBinding = mode: binding: action: {
      inherit action mode;
      key = binding.value;
      desc = binding.description;
    };

    mkSetLuaLznBinding = mode: binding: action: {
      inherit action mode;
      key = binding.value;
      lua = true;
      desc = binding.description;
    };
  };
in
  binds
