# LSP Custom Packages/Command {#sec-languages-custom-lsp-packages}

One of the strengths of **nvf** is convenient aliases to quickly configure LSP
servers through the Nix module system. By default the LSP packages for relevant
language modules will be pulled into the closure. If this is not desirable, you
may provide **a custom LSP package** (e.g., a Bash script that calls a command)
or **a list of strings** to be interpreted as the command to launch the language
server. By using a list of strings, you can use this to skip automatic
installation of a language server, and instead use the one found in your `$PATH`
during runtime, for example:

```nix
vim.languages.java = {
  lsp = {
    enable = true;

    # This expects 'jdt-language-server' to be in your PATH or in
    # 'vim.extraPackages.' There are no additional checks performed to see
    # if the command provided is valid.
    package = ["jdt-language-server" "-data" "~/.cache/jdtls/workspace"];
  };
}
```
