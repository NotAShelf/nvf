{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.tera;
in {
  options.vim.languages.tera = {
    enable = mkEnableOption "Tera templating language support";

    treesitter = {
      enable = mkEnableOption "Tera treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "tera";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })
  ]);
}
