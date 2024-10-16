{
  lib,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) optionalString;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (builtins) attrNames;

  cfg = config.vim.autocomplete.nvim-cmp;
  luasnipEnable = config.vim.snippets.luasnip.enable;
  inherit (cfg) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "nvim-cmp"
        "cmp-buffer"
        "cmp-path"
      ];

      autocomplete.nvim-cmp.sources = {
        nvim-cmp = null;
        buffer = "[Buffer]";
        path = "[Path]";
      };

      autocomplete.nvim-cmp.setupOpts = {
        sources = map (s: {name = s;}) (attrNames cfg.sources);

        # TODO: try to get nvim-cmp to follow global border style
        window = mkIf config.vim.ui.borders.enable {
          completion = mkLuaInline "cmp.config.window.bordered()";
          documentation = mkLuaInline "cmp.config.window.bordered()";
        };

        formatting.format = cfg.format;
      };

      pluginRC.nvim-cmp = mkIf cfg.enable (entryAfter ["autopairs" "luasnip"] ''
        ${optionalString luasnipEnable "local luasnip = require('luasnip')"}
        local cmp = require("cmp")
        cmp.setup(${toLuaObject cfg.setupOpts})
      '');

      # `cmp` and `luasnip` are defined above, in the `nvim-cmp` section
      autocomplete.nvim-cmp.setupOpts.mapping = {
        ${mappings.complete} = mkLuaInline "cmp.mapping.complete()";
        ${mappings.close} = mkLuaInline "cmp.mapping.abort()";
        ${mappings.scrollDocsUp} = mkLuaInline "cmp.mapping.scroll_docs(-4)";
        ${mappings.scrollDocsDown} = mkLuaInline "cmp.mapping.scroll_docs(4)";
        ${mappings.confirm} = mkLuaInline "cmp.mapping.confirm({ select = true })";

        ${mappings.next} = mkLuaInline ''
          cmp.mapping(function(fallback)
            local has_words_before = function()
              local line, col = unpack(vim.api.nvim_win_get_cursor(0))
              return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
            end

            if cmp.visible() then
              cmp.select_next_item()
              ${optionalString luasnipEnable ''
            elseif luasnip.locally_jumpable(1) then
              luasnip.jump(1)
          ''}
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end)
        '';

        ${mappings.previous} = mkLuaInline ''
          cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
              ${optionalString luasnipEnable ''
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
          ''}
            else
              fallback()
            end
          end)
        '';
      };
    };
  };
}
