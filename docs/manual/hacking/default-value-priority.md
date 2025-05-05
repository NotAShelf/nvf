# Default value priority in `listOf` and `attrsOf` options {#sec-listOf-attrsOf-priority}

When defining options of type `listOf` and `attrsOf`, you should pay close
attention to how the default value is defined.

## Default values that should be extended {#ch-extended-defaults}

In most cases, you want user configuration to "extend" your default value, in
this case, your "default" value should be defined using normal priority, i.e. in
a `config` block:

```nix
{lib, ...}: let
  inherit (lib.types) listOf str;
  inherit (lib.options) literalExpression;
in {
  options = {
    vim.telescope.setupOpts.file_ignore_patterns = mkOption {
      type = listOf str;
      # provide a useful defaultText so users are aware of defaults
      defaultText = literalExpression ''
        ["node_modules" "%.git/" "dist/" "build/" "target/" "result/"];
      '';
    };
  };
}
```

This way, when users specify:

```nix
config.vim.telescope.setupOpts.file_ignore_patterns = [".vscode/"];
```

The final value is
`["node_modules" "%.git/" "dist/" "build/" "target/" "result/" ".vscode/"]`.

::: {.note}

Users can still get rid of the default value by assigning a `mkForce` value to
the option:

```nix
{lib, ...}: {
  config.vim.telescope.setupOpts.file_ignore_patterns = lib.mkForce [];
}
```

:::

## Default values that should be overridden {#ch-overridden-defaults}

In some cases, it makes sense to let any user value "override" your default, in
these cases, you should assign default values using default priority, i.e. using
the `default` key of `mkOption`:

```nix
{lib, ...}: let
  inherit (lib.types) listOf str;
  inherit (lib.options) mkOption;
in {
  vim.telescope.setupOpts.pickers.find_files.find_command = mkOption {
    description = "cmd to use for finding files";
    type = listOf str;
    default = ["${pkgs.fd}/bin/fd" "--type=file"];
  }
}
```

This way, when users specify:

```nix
{
  config.vim.telescope.setupOpts.pickers.find_files.find_command = [
    "fd"
    "--type=file"
    "--some-other-option"
  ];
}
```

The final value of the option is `["fd" "--type=file" "--some-other-option"]`.

Users can still choose to "extend" our default value by using `mkDefault`,
possibly with `mkAfter`/`mkBefore`:

```nix
{lib, ...}: {
  config.vim.telescope.setupOpts.pickers.find_files.find_command =
    lib.mkDefault (lib.mkBefore ["--max-depth=10"]);
}
```
