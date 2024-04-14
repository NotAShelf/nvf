{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.utility.vim-wakatime;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      pkgs.vimPlugins.vim-wakatime
    ];

    vim.configRC.vim-wakatime = entryAnywhere ''
      ${
        if cfg.cli-package == null
        then ""
        else ''let g:wakatime_CLIPath = "${cfg.cli-package}"''
      }
    '';
  };
}
