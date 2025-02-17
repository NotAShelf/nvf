{
  lib,
  pkgs,
  config,
  options,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) either listOf package str enum;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.strings) optionalString;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;

  lspKeyConfig = config.vim.lsp.mappings;
  lspKeyOptions = options.vim.lsp.mappings;
  mkLspBinding = optionName: action: let
    key = lspKeyConfig.${optionName};
    desc = lspKeyOptions.${optionName}.description;
  in
    optionalString (key != null) "vim.keymap.set('n', '${key}', ${action}, {buffer=bufnr, noremap=true, silent=true, desc='${desc}'})";

  # Omnisharp doesn't have colors in popup docs for some reason, and I've also
  # seen mentions of it being way slower, so until someone finds missing
  # functionality, this will be the default.
  defaultServer = "csharp_ls";
  servers = {
    omnisharp = {
      package = pkgs.omnisharp-roslyn;
      internalFormatter = true;
      lspConfig = ''
        lspconfig.omnisharp.setup {
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            default_on_attach(client, bufnr)

            local oe = require("omnisharp_extended")
            ${mkLspBinding "goToDefinition" "oe.lsp_definition"}
            ${mkLspBinding "goToType" "oe.lsp_type_definition"}
            ${mkLspBinding "listReferences" "oe.lsp_references"}
            ${mkLspBinding "listImplementations" "oe.lsp_implementation"}
          end,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else "{'${cfg.lsp.package}/bin/OmniSharp'}"
        }
        }
      '';
    };

    csharp_ls = {
      package = pkgs.csharp-ls;
      internalFormatter = true;
      lspConfig = ''
        local extended_handler = require("csharpls_extended").handler

        lspconfig.csharp_ls.setup {
          capabilities = capabilities,
          on_attach = default_on_attach,
          handlers = {
            ["textDocument/definition"] = extended_handler,
            ["textDocument/typeDefinition"] = extended_handler
          },
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else "{'${cfg.lsp.package}/bin/csharp-ls'}"
        }
        }
      '';
    };
  };

  extraServerPlugins = {
    omnisharp = ["omnisharp-extended-lsp-nvim"];
    csharp_ls = ["csharpls-extended-lsp-nvim"];
  };

  cfg = config.vim.languages.csharp;
in {
  options = {
    vim.languages.csharp = {
      enable = mkEnableOption "C# language support";

      treesitter = {
        enable = mkEnableOption "C# treesitter" // {default = config.vim.languages.enableTreesitter;};
        package = mkGrammarOption pkgs "c-sharp";
      };

      lsp = {
        enable = mkEnableOption "C# LSP support" // {default = config.vim.languages.enableLSP;};
        server = mkOption {
          description = "C# LSP server to use";
          type = enum (attrNames servers);
          default = defaultServer;
        };

        package = mkOption {
          description = "C# LSP server package, or the command to run as a list of strings";
          type = either package (listOf str);
          default = servers.${cfg.lsp.server}.package;
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.startPlugins = extraServerPlugins.${cfg.lsp.server} or [];
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.csharp-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
