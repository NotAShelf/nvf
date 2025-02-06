{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.lsp;
in {
  config = mkIf (cfg.enable && cfg.lspSignature.enable) {
    vim = {
      startPlugins = [
        "lsp-signature-nvim"
      ];

      lsp.lspSignature.setupOpts = {
        bind = config.vim.ui.borders.plugins.lsp-signature.enable;
        handler_opts.border = config.vim.ui.borders.plugins.lsp-signature.style;
      };

      pluginRC.lsp-signature = entryAnywhere ''
        -- Enable lsp signature viewer
        require("lsp_signature").setup(${toLuaObject cfg.lspSignature.setupOpts})
      '';
    };
  };
}
