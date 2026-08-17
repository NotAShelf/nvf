{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.visuals.highlight-undo;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.highlight-undo-nvim = {
      package = "highlight-undo-nvim";
      setupModule = "highlight-undo";
      inherit (cfg) setupOpts;
      event = ["BufReadPre" "BufNewFile"];
    };
  };
}
