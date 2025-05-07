# Custom keymaps {#ch-keymaps}

Some plugin modules provide keymap options for convenience. If a keymap is not
provided by such options, you can easily add custom keymaps yourself via
`vim.keymaps`:

```nix
{...}: {
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
