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

## Custom LSP Servers {#ch-custom-lsp-servers}

Neovim 0.11, in an effort to improve the out-of-the-box experience of Neovim,
has introduced a new `vim.lsp` API that can be used to register custom LSP
servers with ease. In **nvf**, this translates to the custom `vim.lsp` API that
can be used to register servers that are not present in existing language
modules.

The {option}`vim.lsp.servers` submodule can be used to modify existing LSP
definitions OR register your own custom LSPs respectively. For example, if you'd
like to avoid having NVF pull the LSP packages you may modify the start command
to use a string, which will cause the LSP API to discover LSP servers from
{env}`PATH`. For example:

```nix
{lib, ...}: { 
  vim.lsp.servers = {
    # Get `basedpyright-langserver` from PATH, e.g., a dev shell.
    basedpyright.cmd = lib.mkForce ["basedpyright-langserver" "--stdio"];

    # Define a custom LSP entry using `vim.lsp.servers`:
    ty = {
      cmd = lib.mkDefault [(lib.getExe pkgs.ty) "server"];
      filetypes = ["python"];
      root_markers = [
        ".git"
        "pyproject.toml"
        "setup.cfg"
        "requirements.txt"
        "Pipfile"
        "pyrightconfig.json"
      ];

    # If your LSP accepts custom settings. See `:help lsp-config` for more details
    # on available fields. This is a freeform field.
    settings.ty = { /* ... */ };
  };
}
```
