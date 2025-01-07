{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.meta) getExe;

  cfg = config.vim.utility.vim-wakatime;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [pkgs.vimPlugins.vim-wakatime];

      # Wakatime configuration is stored as vim globals.
      globals = {
        "wakatime_CLIPath" = mkIf (cfg.cli-package != null) "${getExe cfg.cli-package}";
      };
    };
  };
}
