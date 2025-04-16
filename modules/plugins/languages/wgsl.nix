{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.lists) isList;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.types) either enum listOf package str;
  inherit (lib.nvim.languages) lspOptions;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.wgsl;

  defaultServer = "wgsl-analyzer";
  servers = {
    wgsl-analyzer = {
      package = pkgs.wgsl-analyzer;
      internalFormatter = true;
      options = {
        cmd =
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else "{'${cfg.lsp.package}/bin/wgsl_analyzer'}";
      };
    };
  };
in {
  options.vim.languages.wgsl = {
    enable = mkEnableOption "WGSL language support";

    treesitter = {
      enable = mkEnableOption "WGSL treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "wgsl";
    };

    lsp = {
      enable = mkEnableOption "WGSL LSP support" // {default = config.vim.languages.enableLSP;};
      server = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServer;
        description = "WGSL LSP server to use";
      };

      package = mkOption {
        type = either package (listOf str);
        default = pkgs.wgsl-analyzer;
        example = literalExpression "[(lib.getExe pkgs.wgsl-analyzer)]";
        description = "wgsl-analyzer package, or the command to run as a list of strings";
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
      vim = {
        lsp.lspconfig = {
          enable = true;
          sources.wgsl_analyzer = servers.${cfg.lsp.server}.lspConfig;
        };
      };
    })
  ]);
}
