{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) enum listOf;
  inherit (lib) genAttrs;
  inherit (config.vim.lib) mkLanguageLspEnableOption;

  cfg = config.vim.languages.wgsl;

  defaultServers = ["wgsl-analyzer"];
  servers = ["wgsl-analyzer"];
in {
  options.vim.languages.wgsl = {
    enable = mkEnableOption "WGSL language support";

    treesitter = {
      enable =
        mkEnableOption "WGSL treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "wgsl";
    };

    lsp = {
      enable = mkLanguageLspEnableOption {
        option = "wgsl";
        display = "WGSL";
      };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "WGSL LSP server to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["wgsl"];
        });
      };
    })
  ]);
}
