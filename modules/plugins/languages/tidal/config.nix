{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.vim.tidal;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      # From tidalcycles flake
      pkgs.vimPlugins.vim-tidal
    ];

    vim.globals = {
      "tidal_target" = "terminal";
      "tidal_flash_duration" = 150;
      "tidal_sc_enable" = cfg.openSC;
    };
  };
}
