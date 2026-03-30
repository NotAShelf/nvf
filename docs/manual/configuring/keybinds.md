# Custom keymaps {#ch-keymaps}

Some plugin modules provide keymap options for your convenience. These can be
disabled by toggling {option}`vim.vendoredKeymaps.enable`. It is also possible
to disable individual keymaps with options by setting them to `null`. If a
keymap is not provided by a module, you may easily register your own custom
keymaps via {option}`vim.keymaps`.

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
  ];
}
```
