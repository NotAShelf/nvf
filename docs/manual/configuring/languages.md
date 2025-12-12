# Language Support {#ch-languages}

Language specific support means there is a combination of language specific
plugins, `treesitter` support, `nvim-lspconfig` language servers, `conform-nvim`
formatters, and `nvim-lint` linter integration. This gets you capabilities
ranging from autocompletion to formatting to diagnostics. The following
languages have sections under the `vim.languages` attribute.

- Rust:
  [vim.languages.rust.enable](./options.html#option-vim-languages-rust-enable)
- Nix:
  [vim.languages.nix.enable](./options.html#option-vim-languages-nix-enable)
- SQL:
  [vim.languages.sql.enable](./options.html#option-vim-languages-sql-enable)
- C/C++:
  [vim.languages.clang.enable](./options.html#option-vim-languages-clang-enable)
- Typescript/Javascript:
  [vim.languages.ts.enable](./options.html#option-vim-languages-ts-enable)
- Python:
  [vim.languages.python.enable](./options.html#option-vim-languages-python-enable):
- Zig:
  [vim.languages.zig.enable](./options.html#option-vim-languages-zig-enable)
- Markdown:
  [vim.languages.markdown.enable](./options.html#option-vim-languages-markdown-enable)
- HTML:
  [vim.languages.html.enable](./options.html#option-vim-languages-html-enable)
- Dart:
  [vim.languages.dart.enable](./options.html#option-vim-languages-dart-enable)
- Go: [vim.languages.go.enable](./options.html#option-vim-languages-go-enable)
- Lua:
  [vim.languages.lua.enable](./options.html#option-vim-languages-lua-enable)
- PHP:
  [vim.languages.php.enable](./options.html#option-vim-languages-php-enable)
- F#:
  [vim.languages.fsharp.enable](./options.html#option-vim-languages-fsharp-enable)
- Assembly:
  [vim.languages.assembly.enable](./options.html#option-vim-languages-assembly-enable)
- Astro:
  [vim.languages.astro.enable](./options.html#option-vim-languages-astro-enable)
- Bash:
  [vim.languages.bash.enable](./options.html#option-vim-languages-bash-enable)
- Clang:
  [vim.languages.clang.enable](./options.html#option-vim-languages-clang-enable)
- Clojure:
  [vim.languages.clojure.enable](./options.html#option-vim-languages-clojure-enable)
- C#:
  [vim.languages.csharp.enable](./options.html#option-vim-languages-csharp-enable)
- CSS:
  [vim.languages.css.enable](./options.html#option-vim-languages-css-enable)
- CUE:
  [vim.languages.cue.enable](./options.html#option-vim-languages-cue-enable)
- Elixir:
  [vim.languages.elixir.enable](./options.html#option-vim-languages-elixir-enable)
- Gleam:
  [vim.languages.gleam.enable](./options.html#option-vim-languages-gleam-enable)
- HCL:
  [vim.languages.hcl.enable](./options.html#option-vim-languages-hcl-enable)
- Helm:
  [vim.languages.helm.enable](./options.html#option-vim-languages-helm-enable)
- Julia:
  [vim.languages.julia.enable](./options.html#option-vim-languages-julia-enable)
- Kotlin:
  [vim.languages.kotlin.enable](./options.html#option-vim-languages-kotlin-enable)
- Nim:
  [vim.languages.nim.enable](./options.html#option-vim-languages-nim-enable)
- Nu: [vim.languages.nu.enable](./options.html#option-vim-languages-nu-enable)
- OCaml:
  [vim.languages.ocaml.enable](./options.html#option-vim-languages-ocaml-enable)
- Odin:
  [vim.languages.odin.enable](./options.html#option-vim-languages-odin-enable)
- R: [vim.languages.r.enable](./options.html#option-vim-languages-r-enable)
- Ruby:
  [vim.languages.ruby.enable](./options.html#option-vim-languages-ruby-enable)
- Scala:
  [vim.languages.scala.enable](./options.html#option-vim-languages-scala-enable)
- Svelte:
  [vim.languages.svelte.enable](./options.html#option-vim-languages-svelte-enable)
- Tailwind:
  [vim.languages.tailwind.enable](./options.html#option-vim-languages-tailwind-enable)
- Terraform:
  [vim.languages.terraform.enable](./options.html#option-vim-languages-terraform-enable)
- Typst:
  [vim.languages.typst.enable](./options.html#option-vim-languages-typst-enable)
- Vala:
  [vim.languages.vala.enable](./options.html#option-vim-languages-vala-enable)
- WGSL:
  [vim.languages.wgsl.enable](./options.html#option-vim-languages-wgsl-enable)
- YAML:
  [vim.languages.yaml.enable](./options.html#option-vim-languages-yaml-enable)

Adding support for more languages, and improving support for existing ones are
great places where you can contribute with a PR.

```{=include=} sections
languages/lsp.md
```
