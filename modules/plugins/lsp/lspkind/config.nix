{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkForce;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.lsp.lspkind;
in {
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.vim.autocomplete.nvim-cmp.enable;
        message = ''
          While lspkind supports Neovim's native lsp upstream, using that over
          nvim-cmp isn't recommended, nor supported by nvf.

          Please migrate to nvim-cmp if you want to use lspkind.
        '';
      }
    ];

    vim = {
      startPlugins = ["lspkind"];

      lsp.lspkind.setupOpts.before = config.vim.autocomplete.nvim-cmp.format;
      autocomplete.nvim-cmp.setupOpts.formatting.format = mkForce (mkLuaInline ''
        require("lspkind").cmp_format(${toLuaObject cfg.setupOpts})
      '');
    };
  };
}
