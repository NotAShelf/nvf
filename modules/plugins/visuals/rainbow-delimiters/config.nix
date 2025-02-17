{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  cfg = config.vim.visuals.rainbow-delimiters;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["rainbow-delimiters-nvim"];

    pluginRC.rainbow-delimiters = entryAnywhere ''
      vim.g.rainbow_delimiters = ${toLuaObject cfg.setupOpts}
    '';
  };
}
