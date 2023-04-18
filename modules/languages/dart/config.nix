{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.dart;
  ftcfg = cfg.flutter-tools;
  servers = {
    dart = {
      package = pkgs.dart;
      lspConfig = ''
        lspconfig.dartls.setup{
          capabilities = capabilities;
          on_attach=default_on_attach;
          cmd = {"${pkgs.dart}/bin/dart", "language-server", "--protocol=lsp"};
          ${optionalString (cfg.lsp.opts != null) "init_options = ${cfg.lsp.dartOpts}"}
        }
      '';
    };
  };
in {
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;

      vim.lsp.lspconfig.sources.dart-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf (ftcfg.enable) {
      vim.startPlugins = ["flutter-tools"];

      vim.luaConfigRC.flutter-tools = nvim.dag.entryAnywhere ''
        require('flutter-tools').setup {
          lsp = {
            color = { -- show the derived colours for dart variables
              enabled = ${boolToString ftcfg.color.enable}, -- whether or not to highlight color variables at all, only supported on flutter >= 2.10
              background = ${boolToString ftcfg.color.highlightBackground}, -- highlight the background
              foreground = ${boolToString ftcfg.color.highlightForeground}, -- highlight the foreground
              virtual_text = ${boolToString ftcfg.color.virtualText.enable}, -- show the highlight using virtual text
              virtual_text_str = ${ftcfg.color.virtualText.character} -- the virtual text character to highlight
            },

            capabilities = capabilities,
            on_attach = default_on_attach;
            flags = lsp_flags,
          },
        }

      '';
    })
  ]);
}
