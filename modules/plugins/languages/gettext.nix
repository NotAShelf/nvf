{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.options) mkEnableOption literalExpression;

  cfg = config.vim.languages.gettext;
  # TODO: package `msgfmt --check` into nvim-lint
  # TODO: package `msgcat` into conform.nvim
in {
  options.vim.languages.gettext = {
    enable = mkEnableOption "gettext portable object language support";

    treesitter = {
      enable =
        mkEnableOption "gettext portable object language treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "po";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })
  ]);
}
