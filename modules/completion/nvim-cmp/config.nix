{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.autocomplete;
  lspkindEnabled = config.vim.lsp.enable && config.vim.lsp.lspkind.enable;
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
    then nvim.dag.entryAfter ["lspkind"]
    else nvim.dag.entryAnywhere;
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
    };

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

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
      end

      local cmp = require'cmp'
      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        sources = {
          ${builtSources}
        },
        mapping = {
          ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
          ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c'}),
          ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c'}),
          ['<C-y>'] = cmp.config.disable,
          ['<C-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ['<CR>'] = cmp.mapping.confirm({
            select = true,
          }),
          ['<Tab>'] = cmp.mapping(function (fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif vim.fn['vsnip#available'](1) == 1 then
              feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function (fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.fn['vsnip#available'](-1) == 1 then
              feedkeys("<Plug>(vsnip-jump-prev)", "")
            end
          end, { 'i', 's' })
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
