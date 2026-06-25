{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.helm;

  defaultServers = ["helm-ls"];
  servers = ["helm-ls"];
in {
  options.vim.languages.helm = {
    enable = mkEnableOption "Helm language support";

    treesitter = {
      enable =
        mkEnableOption "Helm treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "helm";
    };

    lsp = {
      enable =
        mkEnableOption "Helm LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Helm LSP server to use";
      };
    };
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
          filetypes = ["helm" "yaml.helm-values"];
        });
      };
    })

    {
      # Enables filetype detection
      vim.startPlugins = [pkgs.vimPlugins.vim-helm];
    }
  ]);
}
