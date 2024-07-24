{
  lib,
  config,
  ...
}: let
  inherit (builtins) toJSON;
  inherit (lib.modules) mkIf;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.strings) optionalString;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;
  cfg = config.vim.lazy;

  toLuaLznSpec = name: spec:
    (removeAttrs spec ["package" "setupModule" "setupOpts"])
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
    };
  lznSpecs = mapAttrsToList toLuaLznSpec cfg.plugins;
in {
  config.vim = mkIf cfg.enable {
    startPlugins = ["lz-n"];

    optPlugins = mapAttrsToList (_: plugin: plugin.package) cfg.plugins;

    luaConfigRC.lzn-load = entryAnywhere ''
      require('lz.n').load(${toLuaObject lznSpecs})
    '';
  };
}
