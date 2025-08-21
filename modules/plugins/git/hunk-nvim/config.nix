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
      startPlugins = [
        # dependencies
        "nui-nvim" # ui library
        "nvim-web-devicons" # glyphs
      ];

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
