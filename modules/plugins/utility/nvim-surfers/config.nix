{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.nvim-surfers;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "nvim-surfers"
      ];

      lazy.plugins.nvim-surfers = {
        package = "nvim-surfers";
        setupModule = "nvim-surfers";
        inherit (cfg) setupOpts;
      };

      extraPackages = [
        pkgs.mplayer
      ];
    };
  };
}

