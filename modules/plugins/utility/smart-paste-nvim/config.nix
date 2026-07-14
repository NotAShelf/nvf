{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.smart-paste-nvim;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.smart-paste-nvim = {
      package = "smart-paste-nvim";
      setupModule = "smart-paste";
      inherit (cfg) setupOpts;

      event = ["DeferredUIEnter"];
    };
  };
}
