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
      startPlugins = ["nui-nvim"];
      visuals.nvim-web-devicons.enable = true;

      lazy.plugins = {
        "hunk-nvim" = {
          package = "hunk-nvim";
          setupModule = "hunk";
          inherit (cfg) setupOpts;
        };
      };
    };
  };
}
