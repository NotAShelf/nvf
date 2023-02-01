{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.tidal;
in {
  options.vim.tidal = {
    enable = mkEnableOption "tidal tools and plugins";

    flash = mkOption {
      description = ''When sending a paragraph or a single line, vim-tidal will "flash" the selection for some milliseconds'';
      type = types.int;
      default = 150;
    };

    openSC = mkOption {
      description = "Automatically run the supercollider CLI, sclang, alongside the Tidal GHCI terminal.";
      type = types.bool;
      default = true;
    };
  };

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
