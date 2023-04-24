{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.terminal.toggleterm;
  toggleKey = "<c-t>";
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "toggleterm-nvim"
    ];

    vim.luaConfigRC.toggleterm = nvim.dag.entryAnywhere (''
        require("toggleterm").setup({
          open_mapping = [[${toggleKey}]],
          direction = '${toString cfg.direction}',
          -- TODO: this should probably be turned into a module that uses the lua function if and only if the user has not set it
          size = function(term)
            if term.direction == "horizontal" then
              return 15
            elseif term.direction == "vertical" then
              return vim.o.columns * 0.4
            end
          end,
          winbar = {
            enabled = '${toString cfg.enable_winbar}',
            name_formatter = function(term) --  term: Terminal
              return term.name
            end
          },
        })
      ''
      + optionalString cfg.lazygit.enable ''

        local terminal = require 'toggleterm.terminal'
        local lazygit = terminal.Terminal:new({
          cmd = "lazygit",
          direction = '${cfg.lazygit.direction}',
          hidden = true,
          on_open = function(term)
            vim.cmd("startinsert!")
            vim.keymap.set( 't', [[${toggleKey}]], function() term:toggle() end, {silent = true, noremap = true, buffer = term.bufnr})
          end
        })

        vim.keymap.set( 'n', [[<leader>gg]], function() lazygit:toggle() end, {silent = true, noremap = true})
      '');
  };
}
