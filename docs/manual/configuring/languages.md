# Language Support {#ch-languages}

Language specific support means there is a combination of language specific
plugins, `treesitter` support, `nvim-lspconfig` language servers, `conform-nvim`
formatters, and `nvim-lint` linter integration. This gets you capabilities
ranging from autocompletion to formatting to diagnostics. The following
languages have sections under the `vim.languages` attribute.

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
- F#: [vim.languages.fsharp.enable](#opt-vim.languages.fsharp.enable)
- Assembly: [vim.languages.assembly.enable](#opt-vim.languages.assembly.enable)
- Astro: [vim.languages.astro.enable](#opt-vim.languages.astro.enable)
- Bash: [vim.languages.bash.enable](#opt-vim.languages.bash.enable)
- Clang: [vim.languages.clang.enable](#opt-vim.languages.clang.enable)
- Clojure: [vim.languages.clojure.enable](#opt-vim.languages.clojure.enable)
- C#: [vim.languages.csharp.enable](#opt-vim.languages.csharp.enable)
- CSS: [vim.languages.css.enable](#opt-vim.languages.css.enable)
- CUE: [vim.languages.cue.enable](#opt-vim.languages.cue.enable)
- Elixir: [vim.languages.elixir.enable](#opt-vim.languages.elixir.enable)
- Gleam: [vim.languages.gleam.enable](#opt-vim.languages.gleam.enable)
- HCL: [vim.languages.hcl.enable](#opt-vim.languages.hcl.enable)
- Helm: [vim.languages.helm.enable](#opt-vim.languages.helm.enable)
- Julia: [vim.languages.julia.enable](#opt-vim.languages.julia.enable)
- Kotlin: [vim.languages.kotlin.enable](#opt-vim.languages.kotlin.enable)
- Nim: [vim.languages.nim.enable](#opt-vim.languages.nim.enable)
- Nu: [vim.languages.nu.enable](#opt-vim.languages.nu.enable)
- OCaml: [vim.languages.ocaml.enable](#opt-vim.languages.ocaml.enable)
- Odin: [vim.languages.odin.enable](#opt-vim.languages.odin.enable)
- R: [vim.languages.r.enable](#opt-vim.languages.r.enable)
- Ruby: [vim.languages.ruby.enable](#opt-vim.languages.ruby.enable)
- Scala: [vim.languages.scala.enable](#opt-vim.languages.scala.enable)
- Svelte: [vim.languages.svelte.enable](#opt-vim.languages.svelte.enable)
- Tailwind: [vim.languages.tailwind.enable](#opt-vim.languages.tailwind.enable)
- Terraform: [vim.languages.terraform.enable](#opt-vim.languages.terraform.enable)
- Typst: [vim.languages.typst.enable](#opt-vim.languages.typst.enable)
- Vala: [vim.languages.vala.enable](#opt-vim.languages.vala.enable)
- WGSL: [vim.languages.wgsl.enable](#opt-vim.languages.wgsl.enable)
- YAML: [vim.languages.yaml.enable](#opt-vim.languages.yaml.enable)

Adding support for more languages, and improving support for existing ones are
great places where you can contribute with a PR.

```{=include=} sections
languages/lsp.md
```
