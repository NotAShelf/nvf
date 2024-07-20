{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) bool;
  inherit (lib.lists) optional;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.languages.html;
in {
  options.vim.languages.html = {
    enable = mkEnableOption "HTML language support";
    treesitter = {
      enable = mkEnableOption "HTML treesitter support" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "html";
      autotagHtml = mkOption {
        description = "Enable autoclose/autorename of html tags (nvim-ts-autotag)";
        type = bool;
        default = true;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim = {
        startPlugins = optional cfg.treesitter.autotagHtml "nvim-ts-autotag";

        treesitter = {
          enable = true;
          grammars = [cfg.treesitter.package];
        };

        pluginRC.html-autotag = mkIf cfg.treesitter.autotagHtml (entryAnywhere ''
          require('nvim-ts-autotag').setup()
        '');
      };
    })
  ]);
}
