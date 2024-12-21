{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.vim.languages.solidity;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim) mkGrammarOption;
in {
  options.vim.languages.solidity = {
    enable = mkEnableOption "Solidity support";

    treesitter = {
      enable = mkEnableOption "Treesitter support for Solidity";
      package = mkGrammarOption pkgs "solidity";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (lib.mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
      };
    })
  ]);
}
