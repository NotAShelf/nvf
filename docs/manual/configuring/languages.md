# Language Support {#ch-languages}

Language specific support means there is a combination of language specific
plugins, `treesitter` support, `nvim-lspconfig` language servers, and `null-ls`
integration. This gets you capabilities ranging from autocompletion to
formatting to diagnostics. The following languages have sections under the
`vim.languages` attribute.

- Rust: [vim.languages.rust.enable](#opt-vim.languages.rust.enable)
- Nix: [vim.languages.nix.enable](#opt-vim.languages.nix.enable)
- SQL: [vim.languages.sql.enable](#opt-vim.languages.sql.enable)
- C/C++: [vim.languages.clang.enable](#opt-vim.languages.clang.enable)
- Typescript/Javascript: [vim.languages.ts.enable](#opt-vim.languages.ts.enable)
- Python: [vim.languages.python.enable](#opt-vim.languages.python.enable):
- Zig: [vim.languages.zig.enable](#opt-vim.languages.zig.enable)
- Markdown: [vim.languages.markdown.enable](#opt-vim.languages.markdown.enable)
- HTML: [vim.languages.html.enable](#opt-vim.languages.html.enable)
- Dart: [vim.languages.dart.enable](#opt-vim.languages.dart.enable)
- Go: [vim.languages.go.enable](#opt-vim.languages.go.enable)
- Lua: [vim.languages.lua.enable](#opt-vim.languages.lua.enable)
- PHP: [vim.languages.php.enable](#opt-vim.languages.php.enable)
- Tex: [vim.languages.tex.enable](#opt-vim.languages.tex.enable)

Adding support for more languages, and improving support for existing ones are
great places where you can contribute with a PR.

```{=include=} sections
languages/lsp.md
```
