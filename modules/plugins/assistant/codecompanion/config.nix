{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.assistant.codecompanion-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "plenary-nvim"
      ];

      lazy.plugins = {
        codecompanion-nvim = {
          package = "codecompanion-nvim";
          setupModule = "codecompanion";
          inherit (cfg) setupOpts;
        };
      };

      treesitter.enable = true;
    };
  };
}
