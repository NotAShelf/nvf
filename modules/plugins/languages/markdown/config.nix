{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;

  cfg = config.vim.languages.markdown;
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
in {
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.mdPackage cfg.treesitter.mdInlinePackage];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.markdown-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
