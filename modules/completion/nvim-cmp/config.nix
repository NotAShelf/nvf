{
  lib,
  config,
  ...
}: let
  inherit (builtins) toJSON;
  inherit (lib) addDescriptionsToMappings concatMapStringsSep attrNames concatStringsSep mapAttrsToList mkIf mkSetLuaBinding mkMerge optionalString;
  inherit (lib.nvim) dag;

  cfg = config.vim.autocomplete;
  lspkindEnabled = config.vim.lsp.enable && config.vim.lsp.lspkind.enable;

  self = import ./nvim-cmp.nix {inherit lib;};
  mappingDefinitions = self.options.vim.autocomplete.mappings;

  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;

  builtSources =
    concatMapStringsSep
    "\n"
    (n: "{ name = '${n}'},")
    (attrNames cfg.sources);

  builtMaps =
    concatStringsSep
    "\n"
    (mapAttrsToList
      (n: v:
        if v == null
        then ""
        else "${n} = '${v}',")
      cfg.sources);

  dagPlacement =
    if lspkindEnabled
    then dag.entryAfter ["lspkind"]
    else dag.entryAnywhere;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "nvim-cmp"
      "cmp-buffer"
      "cmp-vsnip"
      "cmp-path"
      "vim-vsnip"
    ];

    vim.autocomplete.sources = {
      "nvim-cmp" = null;
      "vsnip" = "[VSnip]";
      "buffer" = "[Buffer]";
      "crates" = "[Crates]";
      "path" = "[Path]";
      "copilot" = "[Copilot]";
    };

    vim.maps.insert = mkMerge [
      (mkSetLuaBinding mappings.complete ''
        require('cmp').complete
      '')
      (mkSetLuaBinding mappings.confirm ''
        function()
          if not require('cmp').confirm({ select = true }) then
            local termcode = vim.api.nvim_replace_termcodes(${toJSON mappings.confirm.value}, true, false, true)

            vim.fn.feedkeys(termcode, 'n')
          end
        end
      '')
      (mkSetLuaBinding mappings.next ''
        function()
          local has_words_before = function()
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
          end

          local cmp = require('cmp')

          local feedkey = function(key, mode)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
          end

          if cmp.visible() then
            cmp.select_next_item()
          elseif vim.fn['vsnip#available'](1) == 1 then
            feedkey("<Plug>(vsnip-expand-or-jump)", "")
          elseif has_words_before() then
            cmp.complete()
          else
            local termcode = vim.api.nvim_replace_termcodes(${toJSON mappings.next.value}, true, false, true)

            vim.fn.feedkeys(termcode, 'n')
          end
        end
      '')
      (mkSetLuaBinding mappings.previous ''
        function()
          local cmp = require('cmp')

          local feedkey = function(key, mode)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
          end

          if cmp.visible() then
            cmp.select_prev_item()
          elseif vim.fn['vsnip#available'](-1) == 1 then
            feedkeys("<Plug>(vsnip-jump-prev)", "")
          end
        end
      '')
      (mkSetLuaBinding mappings.close ''
        require('cmp').mapping.abort()
      '')
      (mkSetLuaBinding mappings.scrollDocsUp ''
        require('cmp').mapping.scroll_docs(-4)
      '')
      (mkSetLuaBinding mappings.scrollDocsDown ''
        require('cmp').mapping.scroll_docs(4)
      '')
    ];

    vim.maps.command = mkMerge [
      (mkSetLuaBinding mappings.complete ''
        require('cmp').complete
      '')
      (mkSetLuaBinding mappings.close ''
        require('cmp').mapping.close()
      '')
      (mkSetLuaBinding mappings.scrollDocsUp ''
        require('cmp').mapping.scroll_docs(-4)
      '')
      (mkSetLuaBinding mappings.scrollDocsDown ''
        require('cmp').mapping.scroll_docs(4)
      '')
    ];

    vim.maps.select = mkMerge [
      (mkSetLuaBinding mappings.next ''
        function()
          local cmp = require('cmp')
          local has_words_before = function()
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
          end

          local feedkey = function(key, mode)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
          end

          if cmp.visible() then
            cmp.select_next_item()
          elseif vim.fn['vsnip#available'](1) == 1 then
            feedkey("<Plug>(vsnip-expand-or-jump)", "")
          elseif has_words_before() then
            cmp.complete()
          else
            local termcode = vim.api.nvim_replace_termcodes(${toJSON mappings.next.value}, true, false, true)

            vim.fn.feedkeys(termcode, 'n')
          end
        end
      '')
      (mkSetLuaBinding mappings.previous ''
        function()
          local cmp = require('cmp')

          local feedkey = function(key, mode)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
          end

          if cmp.visible() then
            cmp.select_prev_item()
          elseif vim.fn['vsnip#available'](-1) == 1 then
            feedkeys("<Plug>(vsnip-jump-prev)", "")
          end
        end
      '')
    ];

    # TODO: alternative snippet engines to vsnip
    # https://github.com/hrsh7th/nvim-cmp/blob/main/doc/cmp.txt#L82
    vim.luaConfigRC.completion = mkIf (cfg.type == "nvim-cmp") (dagPlacement ''
      local nvim_cmp_menu_map = function(entry, vim_item)
        -- name for each source
        vim_item.menu = ({
          ${builtMaps}
        })[entry.source.name]
        print(vim_item.menu)
        return vim_item
      end

      ${optionalString lspkindEnabled ''
        lspkind_opts.before = ${cfg.formatting.format}
      ''}

      local cmp = require'cmp'
      cmp.setup({
        ${optionalString (config.vim.ui.borders.enable) ''
        -- explicitly enabled by setting ui.borders.enable = true
        -- TODO: try to get nvim-cmp to follow global border style
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      ''}

        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },

        sources = {
          ${builtSources}
        },

        completion = {
          completeopt = 'menu,menuone,noinsert',
        },

        formatting = {
          format =
      ${
        if lspkindEnabled
        then "lspkind.cmp_format(lspkind_opts)"
        else cfg.formatting.format
      },
        }
      })
      ${optionalString (config.vim.autopairs.enable && config.vim.autopairs.type == "nvim-autopairs") ''
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { text = ""} }))
      ''}
    '');

    vim.snippets.vsnip.enable =
      if (cfg.type == "nvim-cmp")
      then true
      else config.vim.snippets.vsnip.enable;
  };
}
