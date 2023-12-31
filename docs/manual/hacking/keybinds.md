# Keybinds {#sec-keybinds}

As of 0.4, there exists an API for writing your own keybinds and a couple of useful utility functions are available in
the [extended standard library](https://github.com/NotAShelf/neovim-flake/tree/main/lib). The following section contains
a general overview to how you may utilize said functions.

## Custom Key Mappings Support for a Plugin {#sec-custom-key-mappings}

To set a mapping, you should define it in `vim.maps.<<mode>>`.
The available modes are:

- normal
- insert
- select
- visual
- terminal
- normalVisualOp
- visualOnly
- operator
- insertCommand
- lang
- command

An example, simple keybinding, can look like this:

```nix
{
  vim.maps.normal = {
    "<leader>wq" = {
      action = ":wq<CR>";
      silent = true;
      desc = "Save file and quit";
    };
  };
}
```

There are many settings available in the options. Please refer to the
[documentation](https://notashelf.github.io/neovim-flake/options.html#opt-vim.maps.command._name_.action)
to see a list of them.

`neovim-flake` provides a list of helper commands, so that you don't have to write the mapping attribute sets every
time:

- `mkBinding = key: action: desc:` - makes a basic binding, with `silent` set to true.
- `mkExprBinding = key: action: desc:` - makes an expression binding, with `lua`, `silent`, and `expr` set to true.
- `mkLuaBinding = key: action: desc:` - makes an expression binding, with `lua`, and `silent` set to true.

Note that the Lua in these bindings is actual Lua, not pasted into a `:lua` command.
Therefore, you either pass in a function like `require('someplugin').some_function`, without actually calling it,
or you define your own function, like `function() require('someplugin').some_function() end`.

Additionally, to not have to repeat the descriptions, there's another utility function with its own set of functions:

Utility function that takes two attrsets:

- `{ someKey = "some_value" }`
- `{ someKey = { description = "Some Description"; }; }`

and merges them into `{ someKey = { value = "some_value"; description = "Some Description"; }; }`

```
addDescriptionsToMappings = actualMappings: mappingDefinitions:
```

This function can be used in combination with the same `mkBinding` functions as above, except they only take two
arguments - `binding` and `action`, and have different names:

- `mkSetBinding = binding: action:` - makes a basic binding, with `silent` set to true.
- `mkSetExprBinding = binding: action:` - makes an expression binding, with `lua`, `silent`, and `expr` set to true.
- `mkSetLuaBinding = binding: action:` - makes an expression binding, with `lua`, and `silent` set to true.

You can read the source code of some modules to see them in action, but their usage should look something like this:

```nix

# plugindefinition.nix
{lib, ...}: with lib; {
  options.vim.plugin = {
    enable = mkEnableOption "Enable plugin";

    # Mappings should always be inside an attrset called mappings
    mappings = {
      # mkMappingOption is a helper function from lib,
      # that takes a description (which will also appear in which-key),
      # and a default mapping (which can be null)
      toggleCurrentLine = mkMappingOption "Toggle current line comment" "gcc";
      toggleCurrentBlock = mkMappingOption "Toggle current block comment" "gbc";

      toggleOpLeaderLine = mkMappingOption "Toggle line comment" "gc";
      toggleOpLeaderBlock = mkMappingOption "Toggle block comment" "gb";

      toggleSelectedLine = mkMappingOption "Toggle selected comment" "gc";
      toggleSelectedBlock = mkMappingOption "Toggle selected block" "gb";
    };

  };
}

```

```nix

# config.nix
{
  pkgs,
  config,
  lib,
  ...
}:
  with lib;
  with builtins; let
    cfg = config.vim.plugin;
    self = import ./plugindefinition.nix {inherit lib;};
    mappingDefinitions = self.options.vim.plugin;

    # addDescriptionsToMappings is a helper function from lib,
    # that merges mapping values and their descriptions
    # into one nice attribute set
    mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf (cfg.enable) {
    # ...
    vim.maps.normal = mkMerge [
      # mkSetBinding is another helper function from lib,
      # that actually adds the mapping with a description.
      (mkSetBinding mappings.findFiles "<cmd> Telescope find_files<CR>")
      (mkSetBinding mappings.liveGrep "<cmd> Telescope live_grep<CR>")
      (mkSetBinding mappings.buffers "<cmd> Telescope buffers<CR>")
      (mkSetBinding mappings.helpTags "<cmd> Telescope help_tags<CR>")
      (mkSetBinding mappings.open "<cmd> Telescope<CR>")

      (mkSetBinding mappings.gitCommits "<cmd> Telescope git_commits<CR>")
      (mkSetBinding mappings.gitBufferCommits "<cmd> Telescope git_bcommits<CR>")
      (mkSetBinding mappings.gitBranches "<cmd> Telescope git_branches<CR>")
      (mkSetBinding mappings.gitStatus "<cmd> Telescope git_status<CR>")
      (mkSetBinding mappings.gitStash "<cmd> Telescope git_stash<CR>")

      (mkIf config.vim.lsp.enable (mkMerge [
        (mkSetBinding mappings.lspDocumentSymbols "<cmd> Telescope lsp_document_symbols<CR>")
        (mkSetBinding mappings.lspWorkspaceSymbols "<cmd> Telescope lsp_workspace_symbols<CR>")

        (mkSetBinding mappings.lspReferences "<cmd> Telescope lsp_references<CR>")
        (mkSetBinding mappings.lspImplementations "<cmd> Telescope lsp_implementations<CR>")
        (mkSetBinding mappings.lspDefinitions "<cmd> Telescope lsp_definitions<CR>")
        (mkSetBinding mappings.lspTypeDefinitions "<cmd> Telescope lsp_type_definitions<CR>")
        (mkSetBinding mappings.diagnostics "<cmd> Telescope diagnostics<CR>")
      ]))

      (
        mkIf config.vim.treesitter.enable
        (mkSetBinding mappings.treesitter "<cmd> Telescope treesitter<CR>")
      )
    ];
    # ...
  };
}

```

:::{.note}

If you have come across a plugin that has an API that doesn't seem to easily allow custom keybindings,
don't be scared to implement a draft PR. We'll help you get it done.

:::
