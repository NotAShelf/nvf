{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.strings) optionalString;

  cfg = config.vim.lsp;
in {
  config = mkIf (cfg.enable && cfg.lspSignature.enable) {
    vim = {
      startPlugins = [
        "lsp-signature"
      ];

      luaConfigRC.lsp-signature = entryAnywhere ''
        -- Enable lsp signature viewer
        require("lsp_signature").setup({
          ${optionalString config.vim.ui.borders.plugins.lsp-signature.enable ''
          bind = true, -- This is mandatory, otherwise border config won't get registered.
          handler_opts = {
            border = "${config.vim.ui.borders.plugins.lsp-signature.style}"
          }
        ''}
        })
      '';
    };
  };
}
