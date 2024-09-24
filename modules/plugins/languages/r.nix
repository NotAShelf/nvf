{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.r;

  r-with-languageserver = pkgs.rWrapper.override {
    packages = with pkgs.rPackages; [languageserver];
  };

  defaultServer = "r_language_server";
  servers = {
    r_language_server = {
      package = pkgs.writeShellScriptBin "r_lsp" ''
        ${r-with-languageserver}/bin/R --slave -e "languageserver::run()"
      '';
      lspConfig = ''
        lspconfig.r_language_server.setup{
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${lib.getExe cfg.lsp.package}"}''
        }
        }
      '';
    };
  };
in {
  options.vim.languages.r = {
    enable = mkEnableOption "R language support";

    treesitter = {
      enable = mkEnableOption "R treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "r";
    };

    lsp = {
      enable = mkEnableOption "R LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "R LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "R LSP server package, or the command to run as a list of strings";
        example = literalExpression "[ (lib.getExe pkgs.jdt-language-server) \"-data\" \"~/.cache/jdtls/workspace\" ]";
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
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
      vim.lsp.lspconfig.sources.r-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
