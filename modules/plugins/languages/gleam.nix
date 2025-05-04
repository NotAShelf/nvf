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
  inherit (lib.types) enum either listOf package str;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.gleam;

  defaultServer = "gleam";
  servers = {
    gleam = {
      package = pkgs.gleam;
      lspConfig = ''
        lspconfig.gleam.setup{
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/gleam", "lsp"}''
        }
        }
      '';
    };
  };
in {
  options.vim.languages.gleam = {
    enable = mkEnableOption "Gleam language support";

    treesitter = {
      enable = mkEnableOption "Gleam treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "gleam";
    };

    lsp = {
      enable = mkEnableOption "Gleam LSP support" // {default = config.vim.lsp.enable;};

      server = mkOption {
        type = enum (attrNames servers);
        default = defaultServer;
        description = "Gleam LSP server to use";
      };

      package = mkOption {
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
        description = "Gleam LSP server package, or the command to run as a list of strings";
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
      vim.lsp.lspconfig.sources.gleam-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
