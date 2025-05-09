{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.git.gitlinker-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      lazy.plugins = {
        "gitlinker-nvim" = {
          package = "gitlinker-nvim";
          setupModule = "gitlinker";
          inherit (cfg) setupOpts;
          cmd = ["GitLink"];
        };
      };
    };
  };
}
