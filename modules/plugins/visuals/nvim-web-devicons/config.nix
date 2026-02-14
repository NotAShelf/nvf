{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.visuals.nvim-web-devicons;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["nvim-web-devicons"];

      vim.lazy.plugins.icon-picker-nvim = {
        package = "nvim-web-devicons";
        setupModule = "nvim-web-deviconsr";
        event = ["DeferredUIEnter"];
        inherit (cfg) setupOpts;
      };
    };
  };
}
