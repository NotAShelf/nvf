# Queries (`vim.treesitter.queries`)

Queries allow you to change Neovim's behavior based on Tree-sitter.\
Read more about it in the
[neovim docs](https://neovim.io/doc/user/treesitter/#_treesitter-queries).

**Example:**

In the following example, we are creating a custom injection, to highlight the
Lua string after `mkLuaInline`.

```nix
let
  inherit (lib.generators) mkLuaInline;
in {
  foo = mkLuaInline ''
    function bar()
      return 'foobar'
    end
  '';
}
```

```nix
{
  vim.treesitter.queries = [{
    type = "injections";
    filetypes = ["nix"];
    query = ''
      ;; extends

      ((apply_expression
        function: (variable_expression
          name: (identifier) @_func
          (#eq? @_func "mkLuaInline"))

        argument: (indented_string_expression
          (string_fragment) @injection.content)

        (#set! injection.language "lua")
        (#set! injection.combined)))
    '';
  }];
}
```

This will generate a `queries/nix/injections.scm` in a Neovim runtime directory.

> [!NOTE]
> When multiple queries match the same `filetype` and `type`, they are merged.
