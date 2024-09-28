{
  config,
  lib,
  ...
}: let
  inherit (builtins) map mapAttrs filter;
  inherit (lib.options) mkOption;
  inherit (lib.attrsets) mapAttrsToList filterAttrs getAttrs attrValues attrNames;
  inherit (lib.strings) concatLines concatMapStringsSep;
  inherit (lib.trivial) showWarnings;
  inherit (lib.types) str nullOr;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.dag) entryAfter mkLuarcSection resolveDag entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.config) mkBool;

  cfg = config.vim;

  # Most of the keybindings code is highly inspired by pta2002/nixvim.
  # Thank you!
  mapConfigOptions = {
    silent =
      mkBool false
      "Whether this mapping should be silent. Equivalent to adding <silent> to a map.";

    nowait =
      mkBool false
      "Whether to wait for extra input on ambiguous mappings. Equivalent to adding <nowait> to a map.";

    script =
      mkBool false
      "Equivalent to adding <script> to a map.";

    expr =
      mkBool false
      "Means that the action is actually an expression. Equivalent to adding <expr> to a map.";

    unique =
      mkBool false
      "Whether to fail if the map is already defined. Equivalent to adding <unique> to a map.";

    noremap =
      mkBool true
      "Whether to use the 'noremap' variant of the command, ignoring any custom mappings on the defined action. It is highly advised to keep this on, which is the default.";

    desc = mkOption {
      type = nullOr str;
      default = null;
      description = "A description of this keybind, to be shown in which-key, if you have it enabled.";
    };
  };

  genMaps = mode: maps: let
    /*
    Take a user-defined action (string or attrs) and return the following attribute set:
    {
      action = (string) the actual action to map to this key
      config = (attrs) the configuration options for this mapping (noremap, silent...)
    }
    */
    normalizeAction = action: {
      # Extract the values of the config options that have been explicitly set by the user
      config =
        filterAttrs (_: v: v != null)
        (getAttrs (attrNames mapConfigOptions) action);
      action =
        if action.lua
        then mkLuaInline action.action
        else action.action;
    };
  in
    attrValues (mapAttrs
      (key: action: let
        normalizedAction = normalizeAction action;
      in {
        inherit (normalizedAction) action config;
        inherit key;
        inherit mode;
      })
      maps);
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

    toLuaBindings = mode: maps:
      map (value: ''
        vim.keymap.set(${toLuaObject mode}, ${toLuaObject value.key}, ${toLuaObject value.action}, ${toLuaObject value.config})
      '') (genMaps mode maps);

    # I'm not sure if every one of these will work.
    allmap = toLuaBindings "" config.vim.maps.normalVisualOp;
    nmap = toLuaBindings "n" config.vim.maps.normal;
    vmap = toLuaBindings "v" config.vim.maps.visual;
    xmap = toLuaBindings "x" config.vim.maps.visualOnly;
    smap = toLuaBindings "s" config.vim.maps.select;
    imap = toLuaBindings "i" config.vim.maps.insert;
    cmap = toLuaBindings "c" config.vim.maps.command;
    tmap = toLuaBindings "t" config.vim.maps.terminal;
    lmap = toLuaBindings "l" config.vim.maps.lang;
    omap = toLuaBindings "o" config.vim.maps.operator;
    icmap = toLuaBindings "ic" config.vim.maps.insertCommand;

    maps = [
      nmap
      imap
      vmap
      xmap
      smap
      cmap
      omap
      tmap
      lmap
      icmap
      allmap
    ];
    mappings = concatLines (map concatLines maps);
  in {
    vim = {
      luaConfigRC = {
        # `vim.g` and `vim.o`
        globalsScript = entryAnywhere (concatLines globalsScript);
        optionsScript = entryAfter ["basic"] (concatLines optionsScript);

        # Basic
        pluginConfigs = entryAfter ["optionsScript"] pluginConfigs;
        extraPluginConfigs = entryAfter ["pluginConfigs"] extraPluginConfigs;
        mappings = entryAfter ["extraPluginConfigs"] mappings;
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
