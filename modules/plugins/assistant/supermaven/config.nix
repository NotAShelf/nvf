{
  config,
  lib,
  ...
}: let
  cfg = config.vim.assistant.supermaven;
in {
  config = lib.mkIf cfg.enable {
    vim.plugins = {
      supermaven-nvim = {
        package = "supermaven-nvim";
        setupModule = "supermaven-nvim";
        inherit (cfg) setupOpts;
      };
    };
  };
}
