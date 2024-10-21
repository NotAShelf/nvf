{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.snippets.luasnip;
in {
  config = mkIf cfg.enable {
    vim = {
      lazy.plugins = {
        luasnip = {
          package = "luasnip";
          lazy = true;
          after = cfg.loaders;
        };
        cmp-luasnip = mkIf config.vim.autocomplete.nvim-cmp.enable {
          package = "cmp-luasnip";
          lazy = true;
        };
      };
      startPlugins = cfg.providers;
      autocomplete.nvim-cmp.sources = {luasnip = "[LuaSnip]";};
    };
  };
}
