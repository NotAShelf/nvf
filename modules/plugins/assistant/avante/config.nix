{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.assistant.avante-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "plenary-nvim"
        "dressing-nvim"
        "nui-nvim"
      ];

      lazy.plugins = {
        avante-nvim = {
          package = "avante-nvim";
          setupModule = "avante";
          inherit (cfg) setupOpts;
          event = ["DeferredUIEnter"];
        };
      };

      treesitter.enable = true;

      languages.markdown.extensions.render-markdown-nvim.setupOpts.file_types = lib.mkAfter ["Avante"];
    };
  };
}
