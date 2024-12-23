{
  lib,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.generators) mkLuaInline;
  cfg = config.vim.autocomplete.blink-cmp;
in {
  vim = mkIf cfg.enable {
    lazy.plugins.blink-cmp = {
      package = "blink-cmp";
      setupModule = "blink.cmp";
      inherit (cfg) setupOpts;
      event = ["InsertEnter" "CmdlineEnter"];
    };

    autocomplete = {
      enableSharedCmpSources = true;

      blink-cmp.setupOpts = {
        snippets = mkIf config.vim.snippets.luasnip.enable {
          expand = mkLuaInline ''
            function(snippet)
              return require("luasnip").lsp_expand(snippet)
            end
          '';
          active = mkLuaInline ''
            function(filter)
              if filter and filter.direction then
                return require('luasnip').jumpable(filter.direction)
              end
              return require('luasnip').in_snippet()
            end
          '';
          jump = mkLuaInline "function(direction) require('luasnip').jump(direction) end";
        };
      };
    };
  };
}
