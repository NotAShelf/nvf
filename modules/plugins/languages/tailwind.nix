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

  cfg = config.vim.languages.tailwind;

  defaultServer = "tailwindcss-language-server";
  servers = {
    tailwindcss-language-server = {
      package = pkgs.tailwindcss-language-server;
      lspConfig = ''
        lspconfig.tailwindcss.setup {
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/tailwindcss-language-server", "--stdio"}''
        }
        }
      '';
    };
  };
in {
  options.vim.languages.tailwind = {
    enable = mkEnableOption "Tailwindcss language support";

    lsp = {
      enable = mkEnableOption "Tailwindcss LSP support" // {default = config.vim.lsp.enable;};

      server = mkOption {
        description = "Tailwindcss LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "Tailwindcss LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server " - data " " ~/.cache/jdtls/workspace "]'';
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.tailwindcss-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
