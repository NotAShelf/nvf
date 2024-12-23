{
  lib,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.autocomplete.blink-cmp;
  inherit (cfg) mappings;
in {
  vim = mkIf cfg.enable {
    lazy.plugins.blink-cmp = {
      package = "blink-cmp";
      setupModule = "blink.cmp";
      inherit (cfg) setupOpts;
      # TODO: lazy disabled until lspconfig is lazy loaded
      #
      # event = ["InsertEnter" "CmdlineEnter"];
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

        keymap = {
          ${mappings.complete} = ["show" "fallback"];
          ${mappings.close} = ["hide" "fallback"];
          ${mappings.scrollDocsUp} = ["scroll_documentation_up" "fallback"];
          ${mappings.scrollDocsDown} = ["scroll_documentation_down" "fallback"];
          ${mappings.confirm} = ["accept" "fallback"];

          ${mappings.next} = [
            "select_next"
            "snippet_forward"
            (mkLuaInline ''
              function(cmp)
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                has_words_before = col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil

                if has_words_before then
                  return cmp.show()
                end
              end
            '')
            "fallback"
          ];
          ${mappings.previous} = [
            "select_prev"
            "snippet_backward"
            "fallback"
          ];
        };
      };
    };
  };
}
