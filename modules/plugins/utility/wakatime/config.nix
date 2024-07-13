{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.vim-wakatime;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [pkgs.vimPlugins.vim-wakatime];

    vim.luaConfigRC.vim-wakatime = mkIf (cfg.cli-package != null) ''
      vim.g.wakatime_CLIPath = "${cfg.cli-package}"
    '';
  };
}
