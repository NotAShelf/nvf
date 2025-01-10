{
  lib,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.ui.nvim-ufo;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["promise-async"];
      lazy.plugins.nvim-ufo = {
        package = "nvim-ufo";
        setupModule = "ufo";
        inherit (cfg) setupOpts;
      };
    };
  };
}
