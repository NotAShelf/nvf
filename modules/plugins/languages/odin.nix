{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.types) either listOf package str enum;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.types) mkGrammarOption;

  defaultServer = "ols";
  servers = {
    ols = {
      package = pkgs.ols;
      lspConfig = ''
        lspconfig.ols.setup {
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else "{'${cfg.lsp.package}/bin/ols'}"
        }
        }
      '';
    };
  };

  cfg = config.vim.languages.odin;
in {
  options.vim.languages.odin = {
    enable = mkEnableOption "Odin language support";

    treesitter = {
      enable = mkEnableOption "Odin treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "odin";
    };

    lsp = {
      enable = mkEnableOption "Odin LSP support" // {default = config.vim.lsp.enable;};

      server = mkOption {
        type = enum (attrNames servers);
        default = defaultServer;
        description = "Odin LSP server to use";
      };

      package = mkOption {
        description = "Ols package, or the command to run as a list of strings";
        type = either package (listOf str);
        default = pkgs.ols;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.odin-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
