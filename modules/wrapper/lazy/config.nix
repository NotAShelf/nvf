{
  lib,
  config,
  ...
}: let
  inherit (builtins) toJSON typeOf head length filter concatLists concatStringsSep;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.strings) optionalString;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryBefore entryAfter;
  cfg = config.vim.lazy;

  toLuaLznKeySpec = keySpec:
    (removeAttrs keySpec ["key" "lua" "action"])
    // {
      "@1" = keySpec.key;
      "@2" =
        if keySpec.lua
        then mkLuaInline keySpec.action
        else keySpec.action;
    };

  toLuaLznSpec = name: spec:
    (removeAttrs spec ["package" "setupModule" "setupOpts" "keys"])
    // {
      "@1" = name;
      before =
        if spec.before != null
        then
          mkLuaInline ''
            function()
              ${spec.before}
            end
          ''
        else null;

      after =
        if spec.setupModule == null && spec.after == null
        then null
        else
          mkLuaInline ''
            function()
              ${
              optionalString (spec.setupModule != null)
              "require(${toJSON spec.setupModule}).setup(${toLuaObject spec.setupOpts})"
            }
              ${optionalString (spec.after != null) spec.after}
            end
          '';

      keys =
        if typeOf spec.keys == "list" && length spec.keys > 0 && typeOf (head spec.keys) == "set"
        then map toLuaLznKeySpec (filter (keySpec: keySpec.key != null) spec.keys)
        # empty list or str or (listOf str)
        else spec.keys;
    };
  lznSpecs = mapAttrsToList toLuaLznSpec cfg.plugins;

  specToNotLazyConfig = _: spec: ''
    do
      ${optionalString (spec.before != null) spec.before}
      ${optionalString (spec.setupModule != null)
      "require(${toJSON spec.setupModule}).setup(${toLuaObject spec.setupOpts})"}
      ${optionalString (spec.after != null) spec.after}
    end
  '';

  specToKeymaps = _: spec:
    if typeOf spec.keys == "list"
    then map (x: removeAttrs x ["ft"]) (filter (lznKey: lznKey.action != null && lznKey.ft == null) spec.keys)
    else if spec.keys == null || typeOf spec.keys == "string"
    then []
    else [spec.keys];

  notLazyConfig = concatStringsSep "\n" (mapAttrsToList specToNotLazyConfig cfg.plugins);
in {
  config.vim = mkMerge [
    (mkIf cfg.enable {
      startPlugins = ["lz-n" "lzn-auto-require"];

      optPlugins = mapAttrsToList (_: plugin: plugin.package) cfg.plugins;

      luaConfigRC.lzn-load = entryBefore ["pluginConfigs"] ''
        require('lz.n').load(${toLuaObject lznSpecs})
      '';
    })
    
    (mkIf (!cfg.enable) {
      startPlugins = mapAttrsToList (_: plugin: plugin.package) cfg.plugins;
      luaConfigPre =
        concatStringsSep "\n"
        (filter (x: x != null) (mapAttrsToList (_: spec: spec.beforeAll) cfg.plugins));
      luaConfigRC.unlazy = entryAfter ["pluginConfigs"] notLazyConfig;
      keymaps = concatLists (mapAttrsToList specToKeymaps cfg.plugins);
    })
  ];
}
