# LSP Custom Packages/Command {#sec-languages-custom-lsp-packages}

In any of the `opt.languages.<language>.lsp.package` options you can provide your own LSP package, or provide
the command to launch the language server, as a list of strings.

You can use this to skip automatic installation of a language server, and instead
use the one found in your `$PATH` during runtime, for example:

```nix
vim.languages.java = {
  lsp = {
    enable = true;
    package = ["jdt-language-server" "-data" "~/.cache/jdtls/workspace"];
  };
}
```
