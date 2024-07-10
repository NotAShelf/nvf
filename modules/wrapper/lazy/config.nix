{
  lib,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;
  cfg = config.vim.lazy;

  toLuaLznSpec = name: plugin:
    (removeAttrs plugin ["package"])
    // {"@1" = name;};
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
