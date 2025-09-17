{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.lsp.null-ls;
in {
  config = mkIf cfg.enable (mkMerge [
    {
      vim = {
        startPlugins = [
          "none-ls-nvim"
          "plenary-nvim"
        ];

        # null-ls implies that LSP is already being set up
        # as it will hook into LSPs to receive information.
        lsp.enable = true;

        pluginRC.null_ls = entryAfter ["lsp-setup"] ''
          require('null-ls').setup(${toLuaObject cfg.setupOpts})
        '';
      };
    }
  ]);
}
