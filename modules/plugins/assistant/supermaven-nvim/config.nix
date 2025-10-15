{
  config,
  lib,
  ...
}: let
  cfg = config.vim.assistant.supermaven-nvim;
in {
  config = lib.mkIf cfg.enable {
    vim.lazy.plugins = {
      supermaven-nvim = {
        package = "supermaven-nvim";
        setupModule = "supermaven-nvim";
        inherit (cfg) setupOpts;
      };
    };
  };
}
