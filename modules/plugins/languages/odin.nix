{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) isList attrNames;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) either listOf package str enum;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.languages) lspOptions;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.types) mkGrammarOption;

  defaultServer = "ols";
  servers = {
    ols = {
      package = pkgs.ols;
      options = {
        cmd =
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else "{'${getExe cfg.lsp.package}'}";
      };
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
      enable = mkEnableOption "Odin LSP support" // {default = config.vim.languages.enableLSP;};
      server = mkOption {
        type = enum (attrNames servers);
        default = defaultServer;
        description = "Odin LSP server to use";
      };

      package = mkOption {
        type = either package (listOf str);
        default = pkgs.ols;
        description = "Ols package, or the command to run as a list of strings";
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
