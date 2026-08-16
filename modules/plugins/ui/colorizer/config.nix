{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.ui.colorizer;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.nvim-colorizer-lua = {
      package = "nvim-colorizer-lua";
      setupModule = "colorizer";
      inherit (cfg) setupOpts;
      event = ["BufReadPre" "BufNewFile"];
    };
  };
}
