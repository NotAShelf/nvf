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
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;

  cfg = config.vim.languages.css;

  defaultServer = "vscode-langservers-extracted";
  servers = {
    vscode-langservers-extracted = {
      package = pkgs.nodePackages.vscode-langservers-extracted;
      lspConfig = ''
        -- enable (broadcasting) snippet capability for completion
        -- see <https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#cssls>
        local css_capabilities = vim.lsp.protocol.make_client_capabilities()
        css_capabilities.textDocument.completion.completionItem.snippetSupport = true

        -- cssls setup
        lspconfig.cssls.setup {
          capabilities = css_capabilities;
          on_attach = default_on_attach;
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/vscode-css-language-server", "--stdio"}''
        }
        }
      '';
    };
  };
in {
  options.vim.languages.css = {
    enable = mkEnableOption "CSS language support";

    treesitter = {
      enable = mkEnableOption "CSS treesitter" // {default = config.vim.languages.enableTreesitter;};

      package = mkGrammarOption pkgs "css";
    };

    lsp = {
      enable = mkEnableOption "CSS LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "CSS LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "CSS LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server " - data " " ~/.cache/jdtls/workspace "]'';
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
      vim.lsp.lspconfig.sources.tailwindcss-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
