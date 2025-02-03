# Debugging nvf {#sec-debugging-nvf}

There may be instances where the your Nix configuration evaluates to invalid
Lua, or times when you will be asked to provide your built Lua configuration for
easier debugging by nvf maintainers. nvf provides two helpful utilities out of
the box.

**nvf-print-config** and **nvf-print-config-path** will be bundled with nvf as
lightweight utilities to help you view or share your built configuration when
necessary.

To view your configuration with syntax highlighting, you may use the
[bat pager](https://github.com/sharkdp/bat).

```bash
nvf-print-config | bat --language=lua
```

Alternatively, `cat` or `less` may also be used.

## Accessing `neovimConfig` {#sec-accessing-config}

It is also possible to access the configuration for the wrapped package. The
_built_ Neovim package will contain a `neovimConfig` attribute in its
`passthru`.
