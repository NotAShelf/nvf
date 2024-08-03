{
  config,
  lib,
  ...
}: let
  inherit (builtins) map mapAttrs filter removeAttrs attrNames;
  inherit (lib.attrsets) mapAttrsToList filterAttrs attrsToList;
  inherit (lib.strings) concatLines concatMapStringsSep optionalString;
  inherit (lib.trivial) showWarnings;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.dag) entryAfter mkLuarcSection resolveDag entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim;
in {
  config = let
    globalsScript =
      mapAttrsToList (name: value: "vim.g.${name} = ${toLuaObject value}") cfg.globals;

    optionsScript =
      mapAttrsToList (name: value: "vim.o.${name} = ${toLuaObject value}") cfg.options;

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
      inherit (keymap) desc silent nowait script expr unique noremap;
    };

    toLuaKeymap = {
      name,
      value,
    }: "vim.keymap.set(${toLuaObject value.mode}, ${toLuaObject name}, ${toLuaObject (getAction value)}, ${toLuaObject (getOpts value)})";

    namedModes = {
      "normal" = ["n"];
      "insert" = ["i"];
      "select" = ["s"];
      "visual" = ["v"];
      "terminal" = ["t"];
      "normalVisualOp" = ["n" "v" "o"];
      "visualOnly" = ["n" "x"];
      "operator" = ["o"];
      "insertCommand" = ["i" "c"];
      "lang" = ["l"];
      "command" = ["c"];
    };

    maps =
      removeAttrs cfg.maps (attrNames namedModes)
      // mapAttrs (_: legacyMap: legacyMap // {mode = namedModes.normal;}) cfg.maps.normal
      // mapAttrs (_: legacyMap: legacyMap // {mode = namedModes.insert;}) cfg.maps.insert
      // mapAttrs (_: legacyMap: legacyMap // {mode = namedModes.select;}) cfg.maps.select
      // mapAttrs (_: legacyMap: legacyMap // {mode = namedModes.visual;}) cfg.maps.visual
      // mapAttrs (_: legacyMap: legacyMap // {mode = namedModes.terminal;}) cfg.maps.terminal
      // mapAttrs (_: legacyMap: legacyMap // {mode = namedModes.normalVisualOp;}) cfg.maps.normalVisualOp
      // mapAttrs (_: legacyMap: legacyMap // {mode = namedModes.visualOnly;}) cfg.maps.visualOnly
      // mapAttrs (_: legacyMap: legacyMap // {mode = namedModes.operator;}) cfg.maps.operator
      // mapAttrs (_: legacyMap: legacyMap // {mode = namedModes.insertCommand;}) cfg.maps.insertCommand
      // mapAttrs (_: legacyMap: legacyMap // {mode = namedModes.lang;}) cfg.maps.lang
      // mapAttrs (_: legacyMap: legacyMap // {mode = namedModes.command;}) cfg.maps.command;

    keymaps = concatLines (map toLuaKeymap (attrsToList (filterAttrs (_: value: value != null) maps)));
  in {
    vim = {
      luaConfigRC = {
        # `vim.g` and `vim.o`
        globalsScript = entryAnywhere (concatLines globalsScript);
        optionsScript = entryAfter ["basic"] (concatLines optionsScript);

        # Basic
        pluginConfigs = entryAfter ["optionsScript"] pluginConfigs;
        extraPluginConfigs = entryAfter ["pluginConfigs"] extraPluginConfigs;
        mappings = entryAfter ["extraPluginConfigs"] keymaps;
        # FIXME: put this somewhere less stupid
        footer = entryAfter ["mappings"] (optionalString config.vim.lazy.enable "require('lzn-auto-require.loader').register_loader()");
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
