{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) nvim mkIf mkMerge mkBinding isList;

  cfg = config.vim.languages.markdown;
  self = import ./markdown.nix {
    inherit lib config pkgs;
  };
  mappings = self.options.vim.languages.markdown.glow.mappings;
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

      vim.maps.normal = mkMerge [
        (mkBinding cfg.glow.mappings.openPreview ":Glow<CR>" mappings.openPreview.description)
      ];

      vim.luaConfigRC.glow = nvim.dag.entryAnywhere ''
        require('glow').setup({
          glow_path = "${pkgs.glow}/bin/glow"
        });
      '';
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;

      vim.lsp.lspconfig.sources.markdown-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
