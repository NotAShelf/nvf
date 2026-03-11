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
      lazy.plugins.nvim-web-devicons = {
        package = "nvim-web-devicons";
        setupModule = "nvim-web-devicons";
        event = ["DeferredUIEnter"];
        inherit (cfg) setupOpts;
      };
    };
  };
}
