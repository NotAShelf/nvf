{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames concatLists;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.lists) isList;
  inherit (lib.types) bool enum either package listOf str;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.markdown;
  defaultServer = "marksman";
  servers = {
    marksman = {
      package = pkgs.marksman;
      lspConfig = ''
        lspconfig.marksman.setup{
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/marksman", "server"}''
        },
        }
      '';
    };
  };

  defaultFormat = "denofmt";
  formats = {
    denofmt = {
      package = pkgs.deno;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.deno_fmt.with({
            filetypes = ${concatLists cfg.format.extraFiletypes ["markdown"]},
            command = "${cfg.format.package}/bin/deno",
          })
        )
      '';
    };
  };
in {
  options.vim.languages.markdown = {
    enable = mkEnableOption "Markdown markup language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Markdown treesitter";
        type = bool;
        default = config.vim.languages.enableTreesitter;
      };
      mdPackage = mkGrammarOption pkgs "markdown";
      mdInlinePackage = mkGrammarOption pkgs "markdown-inline";
    };

    lsp = {
      enable = mkEnableOption "Enable Markdown LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "Markdown LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "Markdown LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server " - data " " ~/.cache/jdtls/workspace "]'';
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };
    };

    format = {
      enable = mkEnableOption "Markdown formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "Markdown formatter to use";
        type = enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "Markdown formatter package";
        type = package;
        default = formats.${cfg.format.type}.package;
      };

      extraFiletypes = mkOption {
        description = "Extra filetypes to format with the Markdown formatter";
        type = listOf str;
        default = [];
      };
    };
  };
}
