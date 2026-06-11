{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.fff-nvim;
in {
  vim.lazy.plugins."fff-nvim" = mkIf cfg.enable {
    package = "fff-nvim";
    setupModule = "fff";
    inherit (cfg) setupOpts;

    cmd = [
      "FFFFind"
      "FFFScan"
      "FFFRefreshGit"
      "FFFClearCache"
      "FFFHealth"
      "FFFDebug"
      "FFFOpenLog"
    ];
  };
}
