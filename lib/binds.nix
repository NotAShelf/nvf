{lib}: let
  inherit (lib.options) mkOption;
  inherit (lib.modules) mkIf;
  inherit (lib.types) nullOr str submodule bool;
  inherit (lib.attrsets) isAttrs mapAttrs attrsOf;
in rec {
  # mkLuaBinding creates a binding with Lua and silent flags.
  #
  # Arguments:
  # - key: The name of the binding.
  # - action: The action to be performed when the binding is activated.
  # - desc: The description of the binding.
  mkLuaBinding = key: action: desc:
    mkIf (key != null) {
      "${key}" = {
        inherit action desc;
        lua = true;
        silent = true;
      };
    };

  # mkExprBinding creates a binding with Lua, silent, and expr flags.
  #
  # Arguments:
  # - key: The name of the binding.
  # - action: The action to be performed when the binding is activated.
  # - desc: The description of the binding.
  mkExprBinding = key: action: desc:
    mkIf (key != null) {
      "${key}" = {
        inherit action desc;
        lua = true;
        silent = true;
        expr = true;
      };
    };

  # mkBinding creates a binding with silent flag.
  #
  # Arguments:
  # - key: The name of the binding.
  # - action: The action to be performed when the binding is activated.
  # - desc: The description of the binding.
  mkBinding = key: action: desc:
    mkIf (key != null) {
      "${key}" = {
        inherit action desc;
        silent = true;
      };
    };

  # mkMappingOption creates an option that can be null or a string.
  #
  # Arguments:
  # - description: The description of the option.
  # - default: The default value of the option.
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

  # mkSetBinding creates a binding with the provided action and description.
  #
  # Arguments:
  # - binding: The binding to be set.
  # - action: The action to be performed when the binding is activated.
  mkSetBinding = binding: action:
    mkBinding binding.value action binding.description;

  # mkSetExprBinding creates an expression binding with the provided action and description.
  #
  # Arguments:
  # - binding: The binding to be set.
  # - action: The action to be performed when the binding is activated.
  mkSetExprBinding = binding: action:
    mkExprBinding binding.value action binding.description;

  # mkSetLuaBinding creates a Lua binding with the provided action and description.
  #
  # Arguments:
  # - binding: The binding to be set.
  # - action: The action to be performed when the binding is activated.
  mkSetLuaBinding = binding: action:
    mkLuaBinding binding.value action binding.description;
}
