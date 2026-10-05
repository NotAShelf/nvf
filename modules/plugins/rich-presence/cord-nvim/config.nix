{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkForce mkIf;

  cfg = config.vim.presence.cord-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      globals.cord_defer_startup = mkForce true;

      lazy.plugins.cord-nvim = {
        package = "cord-nvim";
        setupModule = "cord";
        inherit (cfg) setupOpts;
        event = ["DeferredUIEnter"];
      };
    };
  };
}
