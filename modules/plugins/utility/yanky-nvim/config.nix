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
  usingShada = cfg.setupOpts.ring.storage == "shada";
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

    assertions = [
      {
        assertion = usingShada -> (config.vim.options.shada or "") != "";
        message = ''
          Yanky.nvim is configured to use 'shada' for the storage backend, but shada is disabled
          in 'vim.options'. Please re-enable shada, or switch to a different backend.
        '';
      }
    ];
  };
}
