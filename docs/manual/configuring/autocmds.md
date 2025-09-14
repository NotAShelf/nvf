# Autocommands and Autogroups {#ch-autocmds-augroups}

This module allows you to declaratively configure Neovim autocommands and
autogroups within your Nix configuration.

## Autogroups (`vim.augroups`) {#sec-vim-augroups}

Autogroups (`augroup`) organize related autocommands. This allows them to be
managed collectively, such as clearing them all at once to prevent duplicates.
Each entry in the list is a submodule with the following options:

| Option   | Type   | Default | Description                                                                                          | Example           |
| :------- | :----- | :------ | :--------------------------------------------------------------------------------------------------- | :---------------- |
| `enable` | `bool` | `true`  | Enables or disables this autogroup definition.                                                       | `true`            |
| `name`   | `str`  | _None_  | **Required.** The unique name for the autogroup.                                                     | `"MyFormatGroup"` |
| `clear`  | `bool` | `true`  | Clears any existing autocommands within this group before adding new ones defined in `vim.autocmds`. | `true`            |

**Example:**

```nix
{
  vim.augroups = [
    {
      name = "MyCustomAuGroup";
      clear = true; # Clear previous autocommands in this group on reload
    }
    {
      name = "Formatting";
      # clear defaults to true
    }
  ];
}
```

## Autocommands (`vim.autocmds`) {#sec-vim-autocmds}

Autocommands (`autocmd`) trigger actions based on events happening within Neovim
(e.g., saving a file, entering a buffer). Each entry in the list is a submodule
with the following options:

| Option     | Type                  | Default | Description                                                                                                             | Example                                                            |
| :--------- | :-------------------- | :------ | :---------------------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------- |
| `enable`   | `bool`                | `true`  | Enables or disables this autocommand definition.                                                                        | `true`                                                             |
| `event`    | `nullOr (listOf str)` | `null`  | **Required.** List of Neovim events that trigger this autocommand (e.g., `BufWritePre`, `FileType`).                    | `[ "BufWritePre" ]`                                                |
| `pattern`  | `nullOr (listOf str)` | `null`  | List of file patterns (globs) to match against (e.g., `*.py`, `*`). If `null`, matches all files for the given event.   | `[ "*.lua", "*.nix" ]`                                             |
| `callback` | `nullOr luaInline`    | `null`  | A Lua function to execute when the event triggers. Use `lib.generators.mkLuaInline`. **Cannot be used with `command`.** | `lib.generators.mkLuaInline "function() print('File saved!') end"` |
| `command`  | `nullOr str`          | `null`  | A Vimscript command to execute when the event triggers. **Cannot be used with `callback`.**                             | `"echo 'File saved!'"`                                             |
| `group`    | `nullOr str`          | `null`  | The name of an `augroup` (defined in `vim.augroups`) to associate this autocommand with.                                | `"MyCustomAuGroup"`                                                |
| `desc`     | `nullOr str`          | `null`  | A description for the autocommand (useful for introspection).                                                           | `"Format buffer on save"`                                          |
| `once`     | `bool`                | `false` | If `true`, the autocommand runs only once and then automatically removes itself.                                        | `false`                                                            |
| `nested`   | `bool`                | `false` | If `true`, allows this autocommand to trigger other autocommands.                                                       | `false`                                                            |

:::{.warning}

You cannot define both `callback` (for Lua functions) and `command` (for
Vimscript) for the same autocommand. Choose one.

:::

**Examples:**

```nix
{ lib, ... }:
{
  vim.augroups = [ { name = "UserSetup"; } ];

  vim.autocmds = [
    # Example 1: Using a Lua callback
    {
      event = [ "BufWritePost" ];
      pattern = [ "*.lua" ];
      group = "UserSetup";
      desc = "Notify after saving Lua file";
      callback = lib.generators.mkLuaInline ''
        function()
          vim.notify("Lua file saved!", vim.log.levels.INFO)
        end
      '';
    }

    # Example 2: Using a Vim command
    {
      event = [ "FileType" ];
      pattern = [ "markdown" ];
      group = "UserSetup";
      desc = "Set spellcheck for Markdown";
      command = "setlocal spell";
    }

    # Example 3: Autocommand without a specific group
    {
      event = [ "BufEnter" ];
      pattern = [ "*.log" ];
      desc = "Disable line numbers in log files";
      command = "setlocal nonumber";
      # No 'group' specified
    }

    # Example 4: Using Lua for callback
    {
      event = [ "BufWinEnter" ];
      pattern = [ "*" ];
      desc = "Simple greeting on entering a buffer window";
      callback = lib.generators.mkLuaInline ''
        function(args)
          print("Entered buffer: " .. args.buf)
        end
      '';
      
      # Run only once per session trigger
      once = true; 
    }
  ];
}
```

These definitions are automatically translated into the necessary Lua code to
configure `vim.api.nvim_create_augroup` and `vim.api.nvim_create_autocmd` when
Neovim starts.
