# From home-manager: https://github.com/nix-community/home-manager/blob/master/modules/lib/stdlib-extended.nix
# Just a convenience function that returns the given Nixpkgs standard
# library extended with the HM library.
nixpkgsLib: let
  mkNvimLib = import ./.;
in
  nixpkgsLib.extend (self: super: rec {
    nvim = mkNvimLib {lib = self;};

    mkLuaBinding = key: action: desc:
      self.mkIf (key != null) {
        "${key}" = {
          inherit action desc;
          lua = true;
          silent = true;
        };
      };

    mkExprBinding = key: action: desc:
      self.mkIf (key != null) {
        "${key}" = {
          inherit action desc;
          lua = true;
          silent = true;
          expr = true;
        };
      };

    mkBinding = key: action: desc:
      self.mkIf (key != null) {
        "${key}" = {
          inherit action desc;
          silent = true;
        };
      };

    mkMappingOption = description: default:
      self.mkOption {
        type = self.types.nullOr self.types.str;
        inherit default description;
      };

    # Utility function that takes two attrsets:
    # { someKey = "some_value" } and
    # { someKey = { description = "Some Description"; }; }
    # and merges them into
    # { someKey = { value = "some_value"; description = "Some Description"; }; }
    addDescriptionsToMappings = actualMappings: mappingDefinitions:
      self.attrsets.mapAttrs (name: value: let
        isNested = self.isAttrs value;
        returnedValue =
          if isNested
          then addDescriptionsToMappings actualMappings."${name}" mappingDefinitions."${name}"
          else {
            value = value;
            description = mappingDefinitions."${name}".description;
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

    # For forward compatibility.
    literalExpression = super.literalExpression or super.literalExample;
  })
