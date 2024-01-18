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
