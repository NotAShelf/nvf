{
  lib,
  config,
  ...
}: let
  inherit (builtins) toJSON;
  inherit (lib.modules) mkIf;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;
  cfg = config.vim.lazy;

  toLznSpec = name: plugin:
    (removeAttrs plugin ["package"])
    // {__HACK = mkLuaInline "nil, [1] = ${toJSON name}";};
  lznSpecs = mapAttrsToList toLznSpec cfg.plugins;
in {
  config.vim = mkIf cfg.enable {
    startPlugins = ["lz-n"];

    optPlugins = mapAttrsToList (_: plugin: plugin.package) cfg.plugins;

    luaConfigRC.lzn-load = entryAnywhere ''
      require('lz.n').load(${toLuaObject lznSpecs})
    '';
  };
}
