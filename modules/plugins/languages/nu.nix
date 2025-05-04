{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) str either package listOf;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (builtins) isList;

  defaultServer = "nushell";
  servers = {
    nushell = {
      package = pkgs.nushell;
      lspConfig = ''
        lspconfig.nushell.setup{
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/nu", "--no-config-file", "--lsp"}''
        }
        }
      '';
    };
  };

  cfg = config.vim.languages.nu;
in {
  options.vim.languages.nu = {
    enable = mkEnableOption "Nu language support";

    treesitter = {
      enable = mkEnableOption "Nu treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "nu";
    };

    lsp = {
      enable = mkEnableOption "Nu LSP support" // {default = config.vim.lsp.enable;};
      server = mkOption {
        type = str;
        default = defaultServer;
        description = "Nu LSP server to use";
      };

      package = mkOption {
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
        example = ''[(lib.getExe pkgs.nushell) "--lsp"]'';
        description = "Nu LSP server package, or the command to run as a list of strings";
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
      vim.lsp.lspconfig.sources.nu-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
