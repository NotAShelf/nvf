{
  config,
  lib,
  ...
}: let
  inherit (builtins) map mapAttrs filter;
  inherit (lib.attrsets) mapAttrsToList;
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

    toLuaKeymap = bind: "vim.keymap.set(${toLuaObject bind.mode}, ${toLuaObject bind.key}, ${toLuaObject (getAction bind)}, ${toLuaObject (getOpts bind)})";

    keymaps = concatLines (map toLuaKeymap (filter (x: x.key != null) cfg.keymaps));
  in {
    vim = {
      luaConfigRC = {
        # `vim.g` and `vim.o`
        globalsScript = entryAnywhere (concatLines globalsScript);
        optionsScript = entryAfter ["basic"] (concatLines optionsScript);

        # Basic
        lazyConfigs = entryAfter ["optionsScript"] cfg.lazy.builtLazyConfig;
        pluginConfigs = entryAfter ["lazyConfigs"] pluginConfigs;
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
              (optionalString (cfg.additionalRuntimePaths != []) ''
                vim.opt.runtimepath:append(${toLuaObject cfg.additionalRuntimePaths})
              '')
              (optionalString cfg.enableLuaLoader ''
                if vim.loader then
                  vim.loader.enable()
                end
              '')
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
