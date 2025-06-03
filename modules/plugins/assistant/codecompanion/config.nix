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

      treesitter = {
        enable = true;

        # Codecompanion depends on the YAML grammar being added. Below is
        # an easy way of adding an user-configurable grammar package exposed
        # by the YAML language module *without* enabling the whole YAML language
        # module. The package is defined even when the module is disabled.
        grammars = [
          config.vim.languages.yaml.treesitter.package
        ];
      };

      autocomplete.nvim-cmp = {
        sources = {codecompanion-nvim = "[codecompanion]";};
        sourcePlugins = ["codecompanion-nvim"];
      };
    };
  };
}
