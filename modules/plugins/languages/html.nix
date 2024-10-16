{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) optional isList;
  inherit (lib.types) enum either package listOf str bool;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.languages.html;

  defaultServer = "html";
  servers = {
    html = {
      package = pkgs.vscode-langservers-extracted;
      lspConfig = ''
        lspconfig.html.setup{
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/vscode-html-language-server",  "--stdio"}''
        };
        }
      '';
    };
  };
in {
  options.vim.languages.html = {
    enable = mkEnableOption "HTML language support";

    lsp = {
      enable = mkEnableOption "Enable HTML LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        type = enum (attrNames servers);
        default = defaultServer;
        description = "HTML LSP server to use";
      };

      package = mkOption {
        type = either package (listOf str);
        default = pkgs.vscode-langservers-extracted;
        description = "html-language-server package, or the command to run as a list of strings";
      };
    };

    treesitter = {
      enable = mkEnableOption "HTML treesitter support" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "html";
      autotagHtml = mkOption {
        description = "Enable autoclose/autorename of html tags (nvim-ts-autotag)";
        type = bool;
        default = true;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.html-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.treesitter.enable {
      vim = {
        startPlugins = optional cfg.treesitter.autotagHtml "nvim-ts-autotag";

        treesitter = {
          enable = true;
          grammars = [cfg.treesitter.package];
        };

        pluginRC.html-autotag = mkIf cfg.treesitter.autotagHtml (entryAnywhere ''
          require('nvim-ts-autotag').setup()
        '');
      };
    })
  ]);
}
