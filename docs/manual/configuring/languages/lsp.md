# LSP Customizations {#sec-lsp-customization}

Neovim 0.11, in an effort to improve the out-of-the-box experience of Neovim,
has introduced a new `vim.lsp` API that can be used to register custom LSP
servers with ease. In **nvf**, this translates to the custom `vim.lsp` API that
can be used to register servers that are not present in existing language
modules.

The {option}`vim.lsp.servers` submodule mirrors the `vim.lsp.config` lua API,
and can be used to modify existing LSP definitions OR register your own custom
LSPs.

## Configuring LSP presets {#ch-configuring-lsp-presets}

LSP presets provided by NVF via `vim.languages.*.lsp` can be further customized
with the {option}`vim.lsp.servers` submodule.

For example, if you'd like to avoid having NVF pull the LSP packages you may
modify the start command to use a string, which will cause the LSP API to
discover LSP servers from {env}`PATH`.

An example for **modifying a preset** provided by NVF via `vim.languages.*.lsp`:

```nix
{lib, ...}: { 
  vim.languages.python = {
    enable = true;
    lsp = {
      enable = true;

      # This is already the default value, we're just writing this down for
      # clarity
      servers = ["basedpyright"]
    };
  };

  vim.lsp.servers = {
    # Get `basedpyright-langserver` from PATH, e.g., a dev shell.
    basedpyright.cmd = lib.mkForce ["basedpyright-langserver" "--stdio"];
  };
}
```

## Adding custom LSP Servers {#ch-custom-lsp}

{option}`vim.lsp.servers` is also used to add your custom LSP definitions.

Example:

```nix
{lib, ...}: {
  vim.lsp.servers = {
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

      # If your LSP accepts custom settings. See `:help lsp-config` for more
      # details on available fields. This is a freeform field.
      settings.ty = { /* ... */ };
    };
  };
}
```
