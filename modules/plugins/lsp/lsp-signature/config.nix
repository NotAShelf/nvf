{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim;

  cfg = config.vim.lsp;
in {
  config = mkIf (cfg.enable && cfg.lspSignature.enable) {
    vim.startPlugins = [
      "lsp-signature"
    ];

    vim.lsp.lspSignature.setupOpts = {
      bind = config.vim.ui.borders.plugins.lsp-signature.enable;
      handler_opts.border = config.vim.ui.borders.plugins.lsp-signature.style;
    };

    vim.luaConfigRC.lsp-signature = nvim.dag.entryAnywhere ''
      -- Enable lsp signature viewer
      require("lsp_signature").setup(${nvim.lua.expToLua cfg.lspSignature.setupOpts})
    '';
  };
}
