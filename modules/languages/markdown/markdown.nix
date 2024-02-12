{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib) mkEnableOption mkMappingOption mkOption types nvim isList;

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
          then nvim.lua.expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/marksman", "server"}''
        },
        }
      '';
    };
  };
in {
  options.vim.languages.markdown = {
    enable = mkEnableOption "Markdown markup language support";

    glow = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable markdown preview in neovim with glow";
      };
      mappings = {
        openPreview = mkMappingOption "Open preview" "<leader>p";
      };
    };

    markdownPreview = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable markdown preview in neovim with markdown-preview.nvim";
      };

      autoStart = mkOption {
        type = types.bool;
        default = false;
        description = "Automatically open the preview window after entering a Markdown buffer";
      };

      autoClose = mkOption {
        type = types.bool;
        default = true;
        description = "Automatically close the preview window after leaving a Markdown buffer";
      };

      lazyRefresh = mkOption {
        type = types.bool;
        default = false;
        description = "Only update preview when saving or leaving insert mode";
      };

      filetypes = mkOption {
        type = types.listOf types.str;
        default = ["markdown"];
        description = "Allowed filetypes";
      };

      alwaysAllowPreview = mkOption {
        type = types.bool;
        default = false;
        description = "Allow preview on all filetypes";
      };

      broadcastServer = mkOption {
        type = types.bool;
        default = false;
        description = "Allow for outside and network wide connections";
      };

      customIP = mkOption {
        type = types.str;
        default = "";
        description = "IP-address to use";
      };

      customPort = mkOption {
        type = types.str;
        default = "";
        description = "Port to use";
      };
    };

    treesitter = {
      enable = mkOption {
        description = "Enable Markdown treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      mdPackage = nvim.types.mkGrammarOption pkgs "markdown";
      mdInlinePackage = nvim.types.mkGrammarOption pkgs "markdown-inline";
    };

    lsp = {
      enable = mkEnableOption "Enable Markdown LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "Markdown LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "Markdown LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server " - data " " ~/.cache/jdtls/workspace "]'';
        type = with types; either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };
    };
  };
}
