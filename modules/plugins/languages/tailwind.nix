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
  inherit (lib.nvim.languages) lspOptions;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.languages.tailwind;

  defaultServer = "tailwindcss-language-server";
  servers = {
    tailwindcss-language-server = {
      package = pkgs.tailwindcss-language-server;
      options = {
        cmd =
          if isList cfg.lsp.package
          then toLuaObject cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/tailwindcss-language-server", "--stdio"}'';
      };
    };
  };
in {
  options.vim.languages.tailwind = {
    enable = mkEnableOption "Tailwindcss language support";

    lsp = {
      enable = mkEnableOption "Tailwindcss LSP support" // {default = config.vim.languages.enableLSP;};
      server = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServer;
        description = "Tailwindcss LSP server to use";
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
