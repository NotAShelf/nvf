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
      startPlugins = ["gitlinker-nvim"];
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
