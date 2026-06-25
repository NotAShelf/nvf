{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  cfg = config.vim.utility.nvim-biscuits;
in {
  config = mkIf cfg.enable {
    vim = {
      lazy.plugins.nvim-biscuits = {
        package = "nvim-biscuits";
        setupModule = "nvim-biscuits";
        setupOpts = cfg.setupOpts;
      };
    };
  };
}
