{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optionals concatLists;

  cfg = config.vim.utility.yanky-nvim;
  usingSqlite = cfg.setupOpts.ring.storage == "sqlite";
  usingShada = cfg.setupOpts.ring.storage == "shada";
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = concatLists [
        (optionals usingSqlite [pkgs.vimPlugins.sqlite-lua])
      ];

      lazy.plugins = {
        "yanky-nvim" = {
          package = "yanky-nvim";
          # TODO: this could maybe be deferred further, but I'm not sure
          setupModule = "yanky";
          event = ["DeferredUIEnter"];
          inherit (cfg) setupOpts;
        };
      };
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
