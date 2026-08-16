{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.ui.smartcolumn;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.smartcolumn-nvim = {
      package = "smartcolumn-nvim";
      setupModule = "smartcolumn";
      inherit (cfg) setupOpts;
      event = ["BufReadPre" "BufNewFile"];
    };
  };
}
