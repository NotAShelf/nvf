# Custom keymaps {#ch-keymaps}

Some plugin modules provide keymap options for your convenience. These can be
disabled by toggling {option}`vim.vendoredKeymaps.enable`. It is also possible
to disable individual keymaps with options by setting them to `null`. If a
keymap is not provided by a module, you may easily register your own custom
keymaps via {option}`vim.keymaps`.

Keymaps can be restricted to specific filetypes by setting `ft`. When `ft` is
non-empty (it defaults to an empty list), the mapping is not created globally;
instead, a `FileType` autocmd registers a buffer-local mapping.

```nix
{
  config.vim.keymaps = [
    {
      key = "<leader>m";
      mode = "n";
      silent = true;
      action = ":make<CR>";
    }
    {
      key = "<leader>l";
      mode = ["n" "x"];
      silent = true;
      action = "<cmd>cnext<CR>";
    }
    {
      key = "<leader>k";
      mode = ["n" "x"];

      # While `lua` is `true`, `action` is expected to be
      # a valid Lua expression.
      lua = true;
      action = ''
        function()
          require('foo').do_thing()
          print('did thing')
        end
      '';
    }
    {
      # `ft` restricts the keymap to buffers of the given filetypes.
      # Instead of a global mapping, a `FileType` autocmd creates a
      # buffer-local mapping when such a buffer is opened.
      key = "<leader>p";
      mode = "n";
      action = "<cmd>Git push<CR>";
      desc = "Push commit";
      ft = ["fugitive"];
    }
  ];
}
```
