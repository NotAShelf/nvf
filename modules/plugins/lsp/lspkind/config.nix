{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkForce;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.lsp.lspkind;
  usingCmp = config.vim.autocomplete.nvim-cmp.enable;
  usingBlink = config.vim.autocomplete.blink-cmp.enable;
in {
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = usingCmp || usingBlink;
        message = ''
          While lspkind supports Neovim's native lsp upstream, using that over
          nvim-cmp/blink.cmp isn't recommended, nor supported by nvf.

          Please migrate to nvim-cmp/blink.cmp if you want to use lspkind.
        '';
      }
    ];

    vim = {
      startPlugins = ["lspkind-nvim"];

      lsp.lspkind.setupOpts.before = config.vim.autocomplete.nvim-cmp.format;
      autocomplete = {
        nvim-cmp = mkIf usingCmp {
          setupOpts.formatting.format = mkForce (mkLuaInline ''
            require("lspkind").cmp_format(${toLuaObject cfg.setupOpts})
          '');
        };

        blink-cmp = mkIf usingBlink {
          setupOpts.appearance.kind_icons = mkLuaInline ''
            require("lspkind").symbol_map
          '';
        };
      };
    };
  };
}
