{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.visuals.neoscroll-nvim;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.neoscroll-nvim = {
      package = "neoscroll-nvim";
      setupModule = "neoscroll";
      inherit (cfg) setupOpts;

      event = ["DeferredUIEnter"];
    };
  };
}
