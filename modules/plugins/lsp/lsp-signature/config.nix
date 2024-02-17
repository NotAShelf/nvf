{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim optionalString;

  cfg = config.vim.lsp;
in {
  config = mkIf (cfg.enable && cfg.lspSignature.enable) {
    vim.startPlugins = [
      "lsp-signature"
    ];

    vim.luaConfigRC.lsp-signature = nvim.dag.entryAnywhere ''
      -- Enable lsp signature viewer
      require("lsp_signature").setup({
        ${optionalString (config.vim.ui.borders.plugins.lsp-signature.enable) ''
        bind = true, -- This is mandatory, otherwise border config won't get registered.
        handler_opts = {
          border = "${config.vim.ui.borders.plugins.lsp-signature.style}"
        }
      ''}
      })
    '';
  };
}
