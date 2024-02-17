{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib) mkEnableOption mkOption mkIf mkMerge isList types nvim;

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
          then nvim.lua.expToLua cfg.lsp.package
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
      enable = mkEnableOption "Tailwindcss LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "Tailwindcss LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "Tailwindcss LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server " - data " " ~/.cache/jdtls/workspace "]'';
        type = with types; either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.css-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
