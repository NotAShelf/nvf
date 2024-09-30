{
  lib,
  config,
  ...
}: let
  inherit (builtins) toJSON typeOf head length tryEval filter;
  inherit (lib.modules) mkIf;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.strings) optionalString;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryBefore;
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

  toLuaLznSpec = spec: let
    name =
      if typeOf spec.package == "string"
      then spec.package
      else if (spec.package ? pname && (tryEval spec.package.pname).success)
      then spec.package.pname
      else spec.package.name;
  in
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
  lznSpecs = map toLuaLznSpec cfg.plugins;
in {
  config.vim = mkIf cfg.enable {
    startPlugins = ["lz-n" "lzn-auto-require"];

    optPlugins = map (plugin: plugin.package) cfg.plugins;

    luaConfigRC.lzn-load = entryBefore ["pluginConfigs"] ''
      require('lz.n').load(${toLuaObject lznSpecs})
    '';
  };
}
