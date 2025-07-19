{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.git.hunk-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      lazy.plugins = {
        "hunk-nvim" = {
          package = "hunk-nvim";
          setupModule = "gitlinker";
          inherit (cfg) setupOpts;
        };
      };
    };
  };
}
