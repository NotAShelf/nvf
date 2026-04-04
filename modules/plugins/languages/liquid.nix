{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.liquid;
in {
  options.vim.languages.liquid = {
    enable = mkEnableOption "Liquid templating language support";

    treesitter = {
      enable =
        mkEnableOption "Liquid treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "liquid";
    };
    # TODO: if curlylint gets packaged for nix, add it.
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })
  ]);
}
