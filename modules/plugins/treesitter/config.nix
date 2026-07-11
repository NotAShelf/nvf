{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf foldl' mapAttrsToList;
  inherit (lib.strings) optionalString;
  inherit (lib.lists) optionals optional partition;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.lua) toLuaObject;

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

      pluginRC = {
        treesitter-autocommands = entryAfter ["basic"] ''
          vim.api.nvim_create_augroup("nvf_treesitter", { clear = true })

          ${lib.optionalString cfg.highlight.enable ''
            -- Enable treesitter highlighting for all filetypes
            vim.api.nvim_create_autocmd("FileType", {
              group = "nvf_treesitter",
              pattern = "*",
              callback = function()
                pcall(vim.treesitter.start)
              end,
            })
          ''}

          ${lib.optionalString cfg.indent.enable ''
            -- Enable treesitter highlighting for all filetypes
            vim.api.nvim_create_autocmd("FileType", {
              group = "nvf_treesitter",
              pattern = ${toLuaObject cfg.indent.pattern},
              callback = function(args)
            ${optionalString (builtins.length cfg.indent.excludes > 0) ''
              local ft = vim.bo[args.buf].filetype
              if vim.tbl_contains(${toLuaObject cfg.indent.excludes}, ft) then
                return
              end
            ''}
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
              end,
            })
          ''}

          ${lib.optionalString cfg.fold ''
            -- Enable treesitter folding for all filetypes
            vim.api.nvim_create_autocmd("FileType", {
              group = "nvf_treesitter",
              pattern = "*",
              callback = function()
                vim.wo[0][0].foldmethod = "expr"
                vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
              end,
            })
          ''}
        '';
        treesitter-filetype-mappings = entryAfter ["basic"] ''
          for lang, ft in pairs(${toLuaObject cfg.filetypeMappings}) do
            vim.treesitter.language.register(lang, ft)
          end
        '';
      };

      additionalRuntimePaths = mkIf (cfg.queries != []) (
        let
          mkQueryGroup = entries:
            foldl' (acc: entry:
              foldl' (inner: filetype: let
                path = "queries/${filetype}/${entry.type}.scm";
                prev = inner.${path} or "";
                query = ''${optionalString (entry.loadtype == "extends") "; extends"} ${entry.query} '';
              in
                inner // {${path} = prev + query;})
              acc
              entry.filetypes)
            {}
            entries;

          mkQueryRuntimePath = name: queries:
            pkgs.linkFarm "treesitter-queries-${name}" (mapAttrsToList (path: query: {
                name = path;
                path = pkgs.writeText path query;
              })
              queries);

          inherit (partition (entry: entry.loadtype == "overwrite") cfg.queries) right wrong;
          overwriteQueries = mkQueryGroup right;
          extendsQueries = mkQueryGroup wrong;
        in
          optional (overwriteQueries != {}) {
            path = mkQueryRuntimePath "overwrite" overwriteQueries;
            position = "prepend";
          }
          ++ optional (extendsQueries != {}) {
            path = mkQueryRuntimePath "extends" extendsQueries;
            position = "append";
          }
      );
    };
  };
}
