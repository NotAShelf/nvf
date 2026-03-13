{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) nullOr either oneOf attrsOf str listOf submodule ints;
  inherit (lib.nvim.types) luaInline;
  inherit (lib.nvim.dag) entryBefore;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim;

  # vim.filetype.add() is quite robust, but this makes for a very
  # complex type that we have to handle. It takes a string, a Lua function
  # or a dictionary with the priority of the extension.
  ftOptionType = attrsOf (oneOf [
    str # "filetype"
    luaInline # `function(path, bufnr) ... end`

    # { 'dosini', { priority = 10 } },
    (listOf (either (either str luaInline) (submodule (submodule {
      options = {
        priority = mkOption {
          type = ints.unsigned;
          description = ''
            `vim.filetype.add()` can take an optional priority value to resolve
            conflicts where a filetype is registered by multiple patterns. When
            priority is specified, file with the higher priority value will be
            matched first on conflict.
          '';
        };
      };
    }))))
  ]);
in {
  options.vim.filetype = mkOption {
    type = submodule {
      options = {
        extension = mkOption {
          type = nullOr ftOptionType;
          default = null;
          description = "register a new filetype by extension";
        };

        filename = mkOption {
          type = nullOr ftOptionType;
          default = null;
          description = "register a new filetype by file name";
        };

        pattern = mkOption {
          type = nullOr ftOptionType;
          default = null;
          description = "register a new filetype by pattern";
        };
      };
    };

    default = {};
    example = {
      filename = {
        ".foorc" = "toml";
        "/etc/foo/config" = "toml";
        "todo.txt" = "todotxt";
      };

      pattern = {
        ".*%.scm" = "query";
        ".*README.(%a+)" = ''
          function(path, bufnr, ext)
            if ext == 'md' then
              return 'markdown'
            elseif ext == 'rst' then
              return 'rst'
            end
          end,
        '';
      };

      extension = {
        mdx = "markdown";
        bar = lib.generators.mkLuaInline ''
          {
            bar = function(path, bufnr)
              if some_condition() then
                return 'barscript', function(bufnr)
                  -- Set a buffer variable
                  vim.b[bufnr].barscript_version = 2
                end
              end
              return 'bar'
            end,
          }
        '';
      };
    };

    description = ''
      Additional filetypes to be registered through `vim.filetype.add()`

      Filetype mappings can be added either by extension or by filename. The
      key can be either the "tail" or the full file path. The full file path
      is checked first, followed by the file name. If a match is not found
      using the filename, then the filename is matched against the list of
      Lua patterns (sorted by priority) until a match is found.

      If a pattern matching does not find a filetype, then the file extension
      is used.

      See `:h vim.filetype.add()` for more details.
    '';
  };

  config = {
    # XXX: some plugins can be loaded on filetype, and unless the filetypes
    # are registered first, chances are custom filetypes will not be usable
    # for lazy-loading on ft.
    vim.luaConfigRC.filetype = entryBefore ["lazyConfigs"] ''
      vim.filetype.add(${toLuaObject cfg.filetype})
    '';
  };
}
