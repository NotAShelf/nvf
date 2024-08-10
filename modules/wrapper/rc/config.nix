{
  config,
  lib,
  ...
}: let
  inherit (builtins) map mapAttrs filter;
  inherit (lib.attrsets) mapAttrsToList filterAttrs attrsToList;
  inherit (lib.strings) concatLines concatMapStringsSep;
  inherit (lib.trivial) showWarnings;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.dag) entryAfter mkLuarcSection resolveDag entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim;
in {
  config = let
    filterNonNull = filterAttrs (_: value: value != null);
    globalsScript =
      mapAttrsToList (name: value: "vim.g.${name} = ${toLuaObject value}")
      (filterNonNull cfg.globals);

    extraPluginConfigs = resolveDag {
      name = "extra plugin configs";
      dag = mapAttrs (_: value: entryAfter value.after value.setup) cfg.extraPlugins;
      mapResult = result: concatLines (map mkLuarcSection result);
    };

    pluginConfigs = resolveDag {
      name = "plugin configs";
      dag = cfg.pluginRC;
      mapResult = result: concatLines (map mkLuarcSection result);
    };

    getAction = keymap:
      if keymap.lua
      then mkLuaInline keymap.action
      else keymap.action;

    getOpts = keymap: {
      inherit (keymap) silent nowait script expr unique noremap;
    };

    toLuaKeymap = {
      name,
      value,
    }: "vim.keymap.set(${toLuaObject value.mode}, ${toLuaObject name}, ${toLuaObject (getAction value)}, ${toLuaObject (getOpts value)})";

    keymaps = concatLines (map toLuaKeymap (attrsToList (filterNonNull cfg.maps)));
  in {
    vim = {
      luaConfigRC = {
        globalsScript = entryAnywhere (concatLines globalsScript);
        # basic, theme
        pluginConfigs = entryAfter ["theme"] pluginConfigs;
        extraPluginConfigs = entryAfter ["pluginConfigs"] extraPluginConfigs;
        mappings = entryAfter ["extraPluginConfigs"] keymaps;
      };

      builtLuaConfigRC = let
        # Catch assertions and warnings
        # and throw for each failed assertion. If no assertions are found, show warnings.
        failedAssertions = map (x: x.message) (filter (x: !x.assertion) config.assertions);
        baseSystemAssertWarn =
          if failedAssertions != []
          then throw "\nFailed assertions:\n${concatMapStringsSep "\n" (x: "- ${x}") failedAssertions}"
          else showWarnings config.warnings;

        luaConfig = resolveDag {
          name = "lua config script";
          dag = cfg.luaConfigRC;
          mapResult = result:
            concatLines [
              cfg.luaConfigPre
              (concatMapStringsSep "\n" mkLuarcSection result)
              cfg.luaConfigPost
            ];
        };
      in
        baseSystemAssertWarn luaConfig;
    };
  };
}
