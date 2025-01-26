{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optionals concatLists;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.utility.yanky-nvim;
  usingSqlite = cfg.setupOpts.ring.storage == "sqlite";
in {
  config = mkIf cfg.enable {
    vim = {
      # TODO: this could probably be lazyloaded. I'm not yet sure which event is
      # ideal, so it's loaded normally for now.
      startPlugins = concatLists [
        ["yanky-nvim"]

        # If using the sqlite backend, sqlite-lua must be loaded
        # alongside yanky.
        (optionals usingSqlite [pkgs.vimPlugins.sqlite-lua])
      ];

      pluginRC.yanky-nvim = entryAnywhere ''
        require("yanky").setup(${toLuaObject cfg.setupOpts});
      '';
    };
  };
}
