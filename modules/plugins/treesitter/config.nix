{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optionals;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.treesitter;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["nvim-treesitter"];

      # cmp-treesitter doesn't work on blink.cmp
      autocomplete.nvim-cmp = mkIf config.vim.autocomplete.nvim-cmp.enable {
        sources = {treesitter = "[Treesitter]";};
        sourcePlugins = ["cmp-treesitter"];
      };

      treesitter.grammars = optionals cfg.addDefaultGrammars cfg.defaultGrammars;

      pluginRC.treesitter-autocommands = entryAfter ["basic"] ''
        vim.api.nvim_create_augroup("nvf_treesitter", { clear = true })

        local has_configs_module = pcall(require, 'nvim-treesitter.configs')

        if has_configs_module then
          -- nvim-treesitter master branch
          require('nvim-treesitter.configs').setup(vim.tbl_deep_extend("force", {
            ${lib.optionalString cfg.highlight.enable ''
          highlight = { enable = true },
        ''}${lib.optionalString cfg.indent.enable ''
          indent = { enable = true },
        ''}
          }, ${lib.nvim.lua.toLuaObject cfg.setupOpts}))
        else
          -- nvim-treesitter main branch
          ${lib.optionalString (cfg.setupOpts != {}) ''
          require('nvim-treesitter').setup(${lib.nvim.lua.toLuaObject cfg.setupOpts})
        ''}
          ${lib.optionalString (cfg.highlight.enable || cfg.indent.enable) ''
          vim.api.nvim_create_autocmd("FileType", {
            group = "nvf_treesitter",
            pattern = "*",
            callback = function()
              ${lib.optionalString cfg.highlight.enable ''
            pcall(vim.treesitter.start)
          ''}${lib.optionalString cfg.indent.enable ''
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          ''}
            end,
          })
        ''}
        end

        ${lib.optionalString cfg.fold ''
          -- Enable treesitter folding for all filetypes
          vim.api.nvim_create_autocmd("FileType", {
            group = "nvf_treesitter",
            pattern = "*",
            callback = function()
              vim.wo[0][0].foldmethod = "expr"
              vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
              -- This is optional, but is set rather as a sane default.
              -- If unset, opened files will be folded by automatically as
              -- the files are opened
              vim.o.foldenable = false
            end,
          })
        ''}
      '';
    };
  };
}
