{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) optionalString;

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
          after = ''
            local path = vim.fn.globpath(vim.o.packpath, 'pack/*/opt/cmp-luasnip')
            require("rtp_nvim").source_after_plugin_dir(path)
          '';
        };
        nvim-cmp.after = optionalString config.vim.lazy.enable ''
          require("lz.n").trigger_load("cmp-luasnip")
        '';
      };
      startPlugins = cfg.providers;
      autocomplete.nvim-cmp.sources = {luasnip = "[LuaSnip]";};
    };
  };
}
