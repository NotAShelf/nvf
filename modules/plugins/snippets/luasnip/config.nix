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
      lazy.plugins.luasnip = {
        package = "luasnip";
        event = "BufEnter";
        after = cfg.loaders;
        setupModule = "luasnip";
        inherit (cfg) setupOpts;
      };
      startPlugins = cfg.providers;
      autocomplete.nvim-cmp = {
        sources = {luasnip = "[LuaSnip]";};
        sourcePlugins = ["cmp-luasnip"];
      };
    };
  };
}
