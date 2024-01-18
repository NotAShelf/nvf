{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) nvim mkIf mkMerge isList;

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
          then nvim.lua.expToLua cfg.lsp.package
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

    (mkIf cfg.glow.enable {
      vim.startPlugins = ["glow-nvim"];

      vim.globals = {
        "glow_binary_path" = "${pkgs.glow}/bin";
      };

      vim.configRC.glow = nvim.dag.entryAnywhere ''
        autocmd FileType markdown noremap <leader>p :Glow<CR>
      '';
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;

      vim.lsp.lspconfig.sources.markdown-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
