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
        "dressing-nvim"
        "nui-nvim"
        "plenary-nvim"
      ];

      lazy.plugins = {
        avante-nvim = {
          package = "avante-nvim";
          setupModule = "avante";
          inherit (cfg) setupOpts;
        };
      };

      treesitter.enable = true;

      autocomplete.nvim-cmp = {
        sources = {avante-nvim = "[avante]";};
        sourcePlugins = ["avante-nvim"];
      };
    };
  };
}
