{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) genAttrs;
  inherit (lib.options) mkEnableOption literalExpression mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.liquid;

  defaultServers = [];
  servers = ["emmet-ls"];
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

    lsp = {
      enable =
        mkEnableOption "Liquid LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        description = "Liquid LSP server to use";
        type = listOf (enum servers);
        default = defaultServers;
      };
    };

    # TODO: if curlylint gets packaged for nix, add it.
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["liquid"];
        });
      };
    })
  ]);
}
