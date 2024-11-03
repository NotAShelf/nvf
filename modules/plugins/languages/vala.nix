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

  cfg = config.vim.languages.vala;

  defaultServer = "vala_ls";
  servers = {
    vala_ls = {
      package = pkgs.writeShellScriptBin "vala-language-server-wrapper" ''
        export PATH="${lib.makeBinPath [pkgs.uncrustify]}:$PATH"
        exec ${pkgs.vala-language-server}/bin/vala-language-server "$@"
      '';
      internalFormatter = true;
      lspConfig = ''
        lspconfig.vala_ls.setup {
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/vala-language-server-wrapper"}''
        },
        }
      '';
    };
  };
in {
  options.vim.languages.vala = {
    enable = mkEnableOption "Vala language support";

    treesitter = {
      enable = mkEnableOption "Vala treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "vala";
    };

    lsp = {
      enable = mkEnableOption "Vala LSP support" // {default = config.vim.languages.enableLSP;};
      server = mkOption {
        description = "Vala LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "Vala LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.vala-language-server]'';
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
      vim.lsp.lspconfig.sources.vala_ls = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
