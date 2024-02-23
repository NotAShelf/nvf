{
  config,
  lib,
  ...
}: let
  inherit (builtins) attrValues attrNames map mapAttrs concatStringsSep filter;
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrsFlatten filterAttrs getAttrs;
  inherit (lib.options) mkOption;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.build) wrapLuaConfig;
  inherit (lib.nvim.vim) valToVim;
  inherit (lib.nvim.bool) mkBool;
  inherit (lib.nvim.dag) resolveDag mkSection entryAnywhere entryAfter;

  cfg = config.vim;

  # Most of the keybindings code is highly inspired by pta2002/nixvim. Thank you!
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
      type = types.nullOr types.str;
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
    normalizeAction = action: let
      # Extract the values of the config options that have been explicitly set by the user
      config =
        filterAttrs (_: v: v != null)
        (getAttrs (attrNames mapConfigOptions) action);
    in {
      config =
        if config == {}
        then {"__empty" = null;}
        else config;
      action =
        if action.lua
        then {"__raw" = action.action;}
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
  imports = [./options.nix];
  config = let
    globalsScript =
      mapAttrsFlatten (name: value: "let g:${name}=${valToVim value}")
      (filterNonNull cfg.globals);

    # TODO: everything below this line needs to be moved to lib
    filterNonNull = mappings: filterAttrs (_name: value: value != null) mappings;

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

    mapResult = r: (wrapLuaConfig (concatStringsSep "\n" (map mkSection r)));
  in {
    vim = {
      startPlugins = map (x: x.package) (attrValues cfg.extraPlugins);
      configRC = {
        globalsScript = entryAnywhere (concatStringsSep "\n" globalsScript);

        luaScript = let
          luaConfig = resolveDag {
            name = "lua config script";
            dag = cfg.luaConfigRC;
            inherit mapResult;
          };
        in
          entryAfter ["globalsScript"] luaConfig;

        extraPluginConfigs = let
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
          mapConfig = wrapLuaConfig (concatStringsSep "\n" (map (v: concatStringsSep "\n" v) maps));
        in
          entryAfter ["globalsScript"] mapConfig;
      };

      builtConfigRC = let
        failedAssertions = map (x: x.message) (filter (x: !x.assertion) config.assertions);

        baseSystemAssertWarn =
          if failedAssertions != []
          then throw "\nFailed assertions:\n${concatStringsSep "\n" (map (x: "- ${x}") failedAssertions)}"
          else lib.showWarnings config.warnings;

        mapResult = r: (concatStringsSep "\n" (map mkSection r));

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
