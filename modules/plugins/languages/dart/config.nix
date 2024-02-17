{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) isList nvim mkIf mkMerge optionalString boolToString;

  cfg = config.vim.languages.dart;
  ftcfg = cfg.flutter-tools;
  servers = {
    dart = {
      package = pkgs.dart;
      lspConfig = ''
        lspconfig.dartls.setup{
          capabilities = capabilities;
          on_attach=default_on_attach;
          cmd = ${
          if isList cfg.lsp.package
          then nvim.lua.expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/dart", "language-server", "--protocol=lsp"}''
        };
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
      vim.startPlugins =
        if ftcfg.enableNoResolvePatch
        then ["flutter-tools-patched"]
        else ["flutter-tools"];

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
          ${optionalString cfg.dap.enable ''
          debugger = {
            enabled = true,
          },
        ''}
        }
      '';
    })
  ]);
}
