{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optionals;
  inherit (lib.strings) optionalString;
  inherit (lib.trivial) boolToString;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.ui.noice;
  tscfg = config.vim.treesitter;
  cmptype = config.vim.autocomplete.type;

  defaultGrammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [vim regex lua bash markdown];
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "noice-nvim"
        "nui-nvim"
      ];

      treesitter.grammars = optionals tscfg.addDefaultGrammars defaultGrammars;

      luaConfigRC.noice-nvim = entryAnywhere ''
        require("noice").setup({
          lsp = {
            override = {
              ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
              ["vim.lsp.util.stylize_markdown"] = true,
              ${optionalString (cmptype == "nvim-cmp") "[\"cmp.entry.get_documentation\"] = true,"}
            },

            signature = {
              enabled = false, -- FIXME: enabling this file throws an error which I couldn't figure out
            },
          },

          hover = {
            enabled = true,
            silent = false, -- set to true to not show a message if hover is not available
            view = nil, -- when nil, use defaults from documentation
            opts = {}, -- merged with defaults from documentation
          },

          presets = {
            bottom_search = true, -- use a classic bottom cmdline for search
            command_palette = true, -- position the cmdline and popupmenu together
            long_message_to_split = true, -- long messages will be sent to a split
            inc_rename = false, -- enables an input dialog for inc-rename.nvim
            lsp_doc_border = ${boolToString config.vim.ui.borders.enable}, -- add a border to hover docs and signature help
          },

          format = {
            cmdline = { pattern = "^:", icon = "", lang = "vim" },
            search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
            search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
            filter = { pattern = "^:%s*!", icon = "", lang = "bash" },
            lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
            help = { pattern = "^:%s*he?l?p?%s+", icon = "󰋖" },
            input = {},
          },

          messages = {
            -- NOTE: If you enable messages, then the cmdline is enabled automatically.
            -- This is a current Neovim limitation.
            enabled = true, -- enables the Noice messages UI
            view = "notify", -- default view for messages
            view_error = "notify", -- view for errors
            view_warn = "notify", -- view for warnings
            view_history = "messages", -- view for :messages
            view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
          },

          -- Hide written messages
          routes = {
            {
              filter = {
                event = "msg_show",
                kind = "",
                find = "written",
              },
              opts = { skip = true },
            },
          },
        })
      '';
    };
  };
}
