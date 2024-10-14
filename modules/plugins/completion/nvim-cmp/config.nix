{
  lib,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) optionalString;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.binds) addDescriptionsToMappings;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (builtins) attrNames;

  cfg = config.vim.autocomplete.nvim-cmp;
  luasnipEnable = config.vim.snippets.luasnip.enable;

  self = import ./nvim-cmp.nix {inherit lib config;};
  mappingDefinitions = self.options.vim.autocomplete.nvim-cmp.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
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
        local luasnip = require("luasnip")
        local cmp = require("cmp")
        cmp.setup(${toLuaObject cfg.setupOpts})
      '');

      # `cmp` and `luasnip` are defined above, in the `nvim-cmp` section
      autocomplete.nvim-cmp.setupOpts.mapping = {
        ${mappings.complete.value} = mkLuaInline "cmp.mapping.complete()";
        ${mappings.close.value} = mkLuaInline "cmp.mapping.abort()";
        ${mappings.scrollDocsUp.value} = mkLuaInline "cmp.mapping.scroll_docs(-4)";
        ${mappings.scrollDocsDown.value} = mkLuaInline "cmp.mapping.scroll_docs(4)";

        ${mappings.confirm.value} = mkLuaInline ''
          cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ select = true })
            else
              fallback()
            end
          end)
        '';

        ${mappings.next.value} = mkLuaInline ''
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

        ${mappings.previous.value} = mkLuaInline ''
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
