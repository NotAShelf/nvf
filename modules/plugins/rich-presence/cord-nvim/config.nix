{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.presence.cord-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      globals.cord_defer_startup = true;

      lazy.plugins.cord-nvim = {
        package = "cord-nvim";
        setupModule = "cord";
        inherit (cfg) setupOpts;
        event = ["DeferredUIEnter"];
      };
    };
  };
}
