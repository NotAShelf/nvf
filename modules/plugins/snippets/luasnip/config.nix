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
      startPlugins = ["luasnip" "cmp-luasnip"] ++ cfg.providers;
      autocomplete.nvim-cmp.sources = {luasnip = "[LuaSnip]";};
      pluginRC.luasnip = cfg.loaders;
    };
  };
}
