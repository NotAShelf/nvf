{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) nvim mkIf mkMerge mkBinding isList concatMapStringsSep;
  inherit (nvim.vim) mkVimBool;

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

    (mkIf cfg.markdownPreview.enable {
      vim.startPlugins = [pkgs.vimPlugins.markdown-preview-nvim];

      vim.configRC.markdown-preview = nvim.dag.entryAnywhere ''
        let g:mkdp_auto_start = ${mkVimBool cfg.markdownPreview.autoStart}
        let g:mkdp_auto_close = ${mkVimBool cfg.markdownPreview.autoClose}
        let g:mkdp_refresh_slow = ${mkVimBool cfg.markdownPreview.lazyRefresh}
        let g:mkdp_filetypes = [${concatMapStringsSep ", " (x: "'" + x + "'") cfg.markdownPreview.filetypes}]
        let g:mkdp_command_for_global = ${mkVimBool cfg.markdownPreview.alwaysAllowPreview}
        let g:mkdp_open_to_the_world = ${mkVimBool cfg.markdownPreview.broadcastServer}
        let g:mkdp_open_ip = '${cfg.markdownPreview.customIP}'
        let g:mkdp_port = '${cfg.markdownPreview.customPort}'
      '';
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;

      vim.lsp.lspconfig.sources.markdown-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
