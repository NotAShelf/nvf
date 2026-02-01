{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  cfg = config.vim.autopairs.nvim-autopairs;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.nvim-autopairs = {
      package = "nvim-autopairs";
      setupModule = "nvim-autopairs";
      setupOpts = cfg.setupOpts;
      event = ["InsertEnter"];
    };
  };
}
