{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) nvim mkIf getExe;

  cfg = config.vim.languages.elixir;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      "elixir-tools"
    ];

    vim.luaConfigRC.elixir-tools = nvim.dag.entryAnywhere ''
        local elixir = require("elixir")
        local elixirls = require("elixir.elixirls")

        elixir.setup {
          elixirls = {


          -- alternatively, point to an existing elixir-ls installation (optional)
          -- not currently supported by elixirls, but can be a table if you wish to pass other args `{"path/to/elixirls", "--foo"}`
          cmd = "${getExe pkgs.elixir-ls}",

          -- default settings, use the `settings` function to override settings
          settings = elixirls.settings {
            dialyzerEnabled = true,
            fetchDeps = false,
            enableTestLenses = false,
            suggestSpecs = false,
          },

          on_attach = function(client, bufnr)
            local map_opts = { buffer = true, noremap = true}

            -- run the codelens under the cursor
            vim.keymap.set("n", "<space>r",  vim.lsp.codelens.run, map_opts)
            -- remove the pipe operator
            vim.keymap.set("n", "<space>fp", ":ElixirFromPipe<cr>", map_opts)
            -- add the pipe operator
            vim.keymap.set("n", "<space>tp", ":ElixirToPipe<cr>", map_opts)
            vim.keymap.set("v", "<space>em", ":ElixirExpandMacro<cr>", map_opts)

            -- bindings for standard LSP functions.
            vim.keymap.set("n", "<space>df", "<cmd>lua vim.lsp.buf.format()<cr>", map_opts)
            vim.keymap.set("n", "<space>gd", "<cmd>lua vim.diagnostic.open_float()<cr>", map_opts)
            vim.keymap.set("n", "<space>dt", "<cmd>lua vim.lsp.buf.definition()<cr>", map_opts)
            vim.keymap.set("n", "<space>K", "<cmd>lua vim.lsp.buf.hover()<cr>", map_opts)
            vim.keymap.set("n", "<space>gD","<cmd>lua vim.lsp.buf.implementation()<cr>", map_opts)
            vim.keymap.set("n", "<space>1gD","<cmd>lua vim.lsp.buf.type_definition()<cr>", map_opts)
            -- keybinds for fzf-lsp.nvim: https://github.com/gfanto/fzf-lsp.nvim
            -- you could also use telescope.nvim: https://github.com/nvim-telescope/telescope.nvim
            -- there are also core vim.lsp functions that put the same data in the loclist
            vim.keymap.set("n", "<space>gr", ":References<cr>", map_opts)
            vim.keymap.set("n", "<space>g0", ":DocumentSymbols<cr>", map_opts)
            vim.keymap.set("n", "<space>gW", ":WorkspaceSymbols<cr>", map_opts)
            vim.keymap.set("n", "<leader>d", ":Diagnostics<cr>", map_opts)
          end
        }
      }
    '';
  };
}
