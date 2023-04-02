{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.lsp;
  ftcfg = cfg.dart.flutter-tools;
in {
  config = mkIf (cfg.enable && ftcfg.enable) {
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
  };
}
