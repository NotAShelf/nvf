{
  lib,
  config,
  ...
}: let
  inherit (builtins) toJSON typeOf head length;
  inherit (lib.modules) mkIf;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.strings) optionalString;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryBefore;
  cfg = config.vim.lazy;

  toLuzLznKeySpec = {
    desc,
    noremap,
    expr,
    nowait,
    ft,
    lhs,
    rhs,
    mode,
  }: {
    "@1" = lhs;
    "@2" = rhs;
    inherit desc noremap expr nowait ft mode;
  };

  toLuaLznSpec = name: spec:
    (removeAttrs spec ["package" "setupModule" "setupOpts" "keys"])
    // {
      "@1" = name;
      after = mkLuaInline ''
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
        then map toLuzLznKeySpec spec.keys
        else spec.keys;
    };
  lznSpecs = mapAttrsToList toLuaLznSpec cfg.plugins;
in {
  config.vim = mkIf cfg.enable {
    startPlugins = ["lz-n"];

    optPlugins = mapAttrsToList (_: plugin: plugin.package) cfg.plugins;

    luaConfigRC.lzn-load = entryBefore ["pluginConfigs"] ''
      require('lz.n').load(${toLuaObject lznSpecs})
    '';
  };
}
