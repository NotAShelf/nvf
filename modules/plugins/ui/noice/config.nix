{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optionals;

  cfg = config.vim.ui.noice;
  tscfg = config.vim.treesitter;

  defaultGrammars = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [vim regex lua bash markdown];
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["nui-nvim"];
      treesitter.grammars = optionals tscfg.addDefaultGrammars defaultGrammars;

      lazy.plugins.noice-nvim = {
        package = "noice-nvim";
        setupModule = "noice";
        event = ["DeferredUIEnter"];
        inherit (cfg) setupOpts;
      };
    };
  };
}
