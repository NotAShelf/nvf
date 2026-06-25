{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.vim-wakatime;
in {
  config = mkIf cfg.enable {
    vim = {
      lazy.plugins."vim-wakatime" = {
        package = "vim-wakatime";
        setupModule = "wakatime";
        inherit (cfg) setupOpts;
      };
    };
  };
}
