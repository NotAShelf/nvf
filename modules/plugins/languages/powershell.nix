{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib) genAttrs;

  cfg = config.vim.languages.powershell;

  defaultServers = ["powershell-editor-services"];
  servers = ["powershell-editor-services"];
in {
  options.vim.languages.powershell = {
    enable = mkEnableOption "PowerShell language support";

    treesitter = {
      enable =
        mkEnableOption "PowerShell treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "powershell";
    };

    lsp = {
      enable =
        mkEnableOption "PowerShell LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "PowerShell LSP servers to use";
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
          filetypes = ["ps1"];
        });
      };
    })
  ]);
}
