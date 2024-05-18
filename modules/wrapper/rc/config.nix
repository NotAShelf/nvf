{
  config,
  lib,
  ...
}: let
  inherit (builtins) map mapAttrs toJSON filter;
  inherit (lib.options) mkOption;
  inherit (lib.attrsets) filterAttrs getAttrs attrValues attrNames;
  inherit (lib.strings) isString concatStringsSep;
  inherit (lib.misc) mapAttrsFlatten;
  inherit (lib.trivial) showWarnings;
  inherit (lib.types) str nullOr;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.dag) entryAnywhere entryAfter topoSort mkLuarcSection mkVimrcSection;
  inherit (lib.nvim.lua) toLuaObject wrapLuaConfig;
  inherit (lib.nvim.vim) valToVim;
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
    filterNonNull = mappings: filterAttrs (_name: value: value != null) mappings;
    globalsScript =
      mapAttrsFlatten (name: value: "let g:${name}=${valToVim value}")
      (filterNonNull cfg.globals);

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

    resolveDag = {
      name,
      dag,
      mapResult,
    }: let
      # When the value is a string, default it to dag.entryAnywhere
      finalDag = mapAttrs (_: value:
        if isString value
        then entryAnywhere value
        else value)
      dag;
      sortedDag = topoSort finalDag;
      result =
        if sortedDag ? result
        then mapResult sortedDag.result
        else abort ("Dependency cycle in ${name}: " + toJSON sortedDag);
    in
      result;
  in {
    vim = {
      configRC = {
        globalsScript = entryAnywhere (concatStringsSep "\n" globalsScript);

        # Call additional lua files with :luafile in Vimscript
        # section of the configuration, only after
        # the luaScript section  has been evaluated
        extraLuaFiles = let
          callLuaFiles = map (file: "luafile ${file}") cfg.extraLuaFiles;
        in
          entryAfter ["globalScript"] (concatStringsSep "\n" callLuaFiles);

        # wrap the lua config in a lua block
        # using the wrapLuaConfic function from the lib
        luaScript = let
          mapResult = result: (wrapLuaConfig {
            luaBefore = "${cfg.luaConfigPre}";
            luaConfig = concatStringsSep "\n" (map mkLuarcSection result);
            luaAfter = "${cfg.luaConfigPost}";
          });

          luaConfig = resolveDag {
            name = "lua config script";
            dag = cfg.luaConfigRC;
            inherit mapResult;
          };
        in
          entryAnywhere luaConfig;

        extraPluginConfigs = let
          mapResult = result: (wrapLuaConfig {
            luaConfig = concatStringsSep "\n" (map mkLuarcSection result);
          });

          extraPluginsDag = mapAttrs (_: {
            after,
            setup,
            ...
          }:
            entryAfter after setup)
          cfg.extraPlugins;

          pluginConfig = resolveDag {
            name = "extra plugins config";
            dag = extraPluginsDag;
            inherit mapResult;
          };
        in
          entryAfter ["luaScript"] pluginConfig;

        # This is probably not the right way to set the config. I'm not sure how it should look like.
        mappings = let
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
          mapConfig = wrapLuaConfig {luaConfig = concatStringsSep "\n" (map (v: concatStringsSep "\n" v) maps);};
        in
          entryAfter ["globalsScript"] mapConfig;
      };

      builtConfigRC = let
        # Catch assertions and warnings
        # and throw for each failed assertion. If no assertions are found, show warnings.
        failedAssertions = map (x: x.message) (filter (x: !x.assertion) config.assertions);
        baseSystemAssertWarn =
          if failedAssertions != []
          then throw "\nFailed assertions:\n${concatStringsSep "\n" (map (x: "- ${x}") failedAssertions)}"
          else showWarnings config.warnings;

        mapResult = result: (concatStringsSep "\n" (map mkVimrcSection result));
        vimConfig = resolveDag {
          name = "vim config script";
          dag = cfg.configRC;
          inherit mapResult;
        };
      in
        baseSystemAssertWarn vimConfig;
    };
  };
}
