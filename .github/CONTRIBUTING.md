# Contribution Guidelines

## Table of Contents

- [Welcome](#welcome)
- [Contributing](#contributing)
- [Code of Conduct](#code-of-conduct)

## Welcome

I'm glad you are thinking about contributing to neovim-flake! If you're unsure about anything, just ask -- or submit the issue or pull request anyway. The worst that can happen is you'll be politely asked to change something. Friendly contributions are always welcome.

Before you contribute, I encourage you to read this project's CONTRIBUTING policy (you are here), its [LICENSE](LICENSE.md), and its [README](README.md).

If you have any questions regarding those files, feel free to open an issue or [shoot me an email](mailto:me@notashelf.dev). Discussions tab is also available for more informal discussions.

## Contributing

The contribution process is mostly documented in the [pull request template](.github/pull_request_template.md). You will find a checklist of items to complete before submitting a pull request. Please make sure you complete it before submitting a pull request. If you are unsure about any of the items, please ask.

### Code of Conduct

This project does not quite have a code of conduct yet. And to be honest, I'm not sure if I want one. I'm not expecting this project to be a hotbed of activity, but I do want to make sure that everyone who does contribute feels welcome and safe. As such, I will do my best to make sure that those who distrupt the project are dealt with swiftly and appropriately.

If you feel that you are not being treated with respect, please contact me directly.

### Guidelines

Here are the overall boundaries I would like you to follow while contributing to neovim-flake.

#### Documentation

If you are making a pull request to add a 


#### Style

**Nix**
We use Alejandra for formatting nix code, which can be invoked directly with `nix fmt` in the repository. 

While Alejandra is mostly opinionated on how code looks after formatting, certain formattings are done at the user's discretion.

Please use one line code for attribute sets that contain only one subset.
For example:

```nix 
# parent modules should always be unfolded
module = { 
    value = mkEnableOption "some description" // { default = true; };
    # same as parent modules, unfold submodules
    subModule = {
        # this is an option that contains more than one nested value
        someOtherValue = mkOption {
            type = lib.types.bool;
            description = "Some other description"
            default = true;
        };
    };
}
```

If you move a line down after the merge operator, Alejandra will automatically unfold the whole merged attrset for you, which we do not want.

```nix
module = {
    key = mkEnableOption "some description" // {
        default = true; # we want this to be inline
    }; 
    # ...
}
```

For lists, it's up mostly to your discretion but please try to avoid unfolded lists if there is only one item in the list.
```nix

# ok 
acceptableList = [
    item1
    item2
    item3
    item4
];

# not ok
listToBeAvoided = [item1 item2 item3 item4];
```

*This will be moved elsewhere, disregard unless you are adding a new plugin with keybinds*
#### Keybinds

#####  Custom key mappings support for a plugin

To add custom keymappings to a plugin, a couple of helper functions are available in the project.

To set a mapping, you should define it on `vim.maps.<mode>`.
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

There are many settings available in the options. Please refer to [the documentation](https://notashelf.github.io/neovim-flake/options.html#opt-vim.maps.command._name_.action) to see a list of them.

neovim-flake provides a list of helper commands, so that you don't have to write the mapping attribute sets every time:

`mkBinding = key: action: desc:` - makes a basic binding, with `silent` set to true.  
`mkExprBinding = key: action: desc:` - makes an expression binding, with `lua`, `silent`, and `expr` set to true.  
`mkLuaBinding = key: action: desc:` - makes an expression binding, with `lua`, and `silent` set to true.  
Note - the lua in these bindings is _actual_ lua, not pasted into a `:lua`.  
Therefore, you either pass in a function like `require('someplugin').some_function`, without actually calling it,
or you define your own function, like `function() require('someplugin').some_function() end`.

Additionally, to not have to repeat the descriptions, there's another utility function with its own set of functions:

```nix
# Utility function that takes two attrsets:
# { someKey = "some_value" } and
# { someKey = { description = "Some Description"; }; }
# and merges them into
# { someKey = { value = "some_value"; description = "Some Description"; }; }

addDescriptionsToMappings = actualMappings: mappingDefinitions:
```

This function can be used in combination with the same mkBinding functions as above, except they only take two arguments - `binding` and `action`, and have different names.  
`mkSetBinding = binding: action:` - makes a basic binding, with `silent` set to true.  
`mkSetExprBinding = binding: action:` - makes an expression binding, with `lua`, `silent`, and `expr` set to true.  
`mkSetLuaBinding = binding: action:` - makes an expression binding, with `lua`, and `silent` set to true.

You can read the source code of some modules to see them in action, but their usage should look something like this:

```nix
# plugindefinition.nix
{lib, ...}:
with lib; {
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

If you have come across a plugin that has an API that doesn't seem to easily allow custom keybindings, don't be scared to implement a draft PR. We'll help you get it done.


