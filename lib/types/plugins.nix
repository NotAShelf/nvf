{
  inputs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.attrsets) attrNames mapAttrs' filterAttrs nameValuePair;
  inherit (lib.strings) hasPrefix removePrefix isString;
  inherit (lib.types) submodule either package enum str lines attrsOf anything listOf nullOr;

  # Get the names of all flake inputs that start with the given prefix.
  fromInputs = inputs: prefix:
    mapAttrs' (n: v: nameValuePair (removePrefix prefix n) {src = v;}) (filterAttrs (n: _: hasPrefix prefix n) inputs);

  pluginsFromInputs = attrNames (fromInputs inputs "plugin-");

  #  Get the names of all flake inputs that start with the given prefix.

  # You can either use the name of the plugin or a package.
  pluginType = nullOr (
    either
    package
    (enum (pluginsFromInputs ++ ["nvim-treesitter" "flutter-tools-patched" "vim-repeat"]))
  );

  pluginsType = listOf pluginType;

  extraPluginType = submodule {
    options = {
      package = mkOption {
        type = pluginType;
        description = "Plugin Package.";
      };

      after = mkOption {
        type = listOf str;
        default = [];
        description = "Setup this plugin after the following ones.";
      };

      setup = mkOption {
        type = lines;
        default = "";
        description = "Lua code to run during setup.";
        example = "require('aerial').setup {}";
      };
    };
  };
in {
  inherit extraPluginType;

  pluginsOpt = {
    description,
    default ? [],
  }:
    mkOption {
      inherit description default;
      type = pluginsType;
    };

  luaInline = lib.mkOptionType {
    name = "luaInline";
    check = x: lib.nvim.lua.isLuaInline x || builtins.isString x;
    merge = loc: defs: let
      val =
        if isString loc
        then lib.generators.mkLuaInline loc
        else loc;
    in
      lib.mergeOneOption val defs;
  };

  /*
  opts is a attrset of options, example:
  ```
  mkPluginSetupOption "telescope" {
    file_ignore_patterns = mkOption {
      description = "...";
      type = types.listOf types.str;
      default = [];
    };
    layout_config.horizontal = mkOption {...};
  }
  ```
  */
  mkPluginSetupOption = pluginName: opts:
    mkOption {
      description = "Option table to pass into the setup function of " + pluginName;
      default = {};
      type = submodule {
        freeformType = attrsOf anything;
        options = opts;
      };
    };
}
