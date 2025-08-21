# Configuring nvf {#ch-configuring}

<!-- markdownlint-disable MD051 -->

[helpful tips section]: #ch-helpful-tips

<!-- markdownlint-enable MD051 -->

nvf allows for _very_ extensive configuration for your Neovim setups through a
Nix module interface. This interface allows you to express almost everything
using a single DSL, Nix. The below chapters describe several of the options
exposed in nvf for your convenience. You might also be interested in the
[helpful tips section] for more advanced or unusual configuration options
supported by nvf such as Nix/Lua hybrid setups.

::: {.note}

This section does not cover module _options_. For an overview of all module
options provided by nvf, please visit the [appendix](/nvf/options.html)

:::

```{=include=} chapters
configuring/custom-package.md
configuring/custom-plugins.md
configuring/overriding-plugins.md

configuring/modules.md
configuring/languages.md
configuring/autocmds.md

configuring/dags.md
configuring/dag-entries.md
```
