{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.ui.breadcrumbs;
  nb = cfg.navbuddy;

  nilOrStr = v:
    if v == null
    then "nil"
    else toString v;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "nvim-navbuddy"
      "nvim-navic"
      "nvim-lspconfig"
    ];

    vim.luaConfigRC.breadcrumbs = nvim.dag.entryAfter ["lspconfig"] ''
      local navbuddy = require("nvim-navbuddy")
      local navic = require("nvim-navic")
      local actions = require("nvim-navbuddy.actions")

      -- TODO: wrap this in an optional string with navbuddy as the enable condition
      navbuddy.setup {
          window = {
              border = "${nb.window.border}",  -- "rounded", "double", "solid", "none"
              size = "60%",
              position = "50%",
              scrolloff = ${(nilOrStr nb.window.scrolloff)},
              sections = {
                  left = {
                      size = "20%",
                      border = ${(nilOrStr nb.window.sections.left.border)},
                  },

                  mid = {
                      size = "40%",
                      border = ${(nilOrStr nb.window.sections.mid.border)},
                  },

                  right = {
                      border = ${(nilOrStr nb.window.sections.right.border)},
                      preview = "leaf",
                  }
              },
          },
          node_markers = {
              enabled = ${boolToString nb.nodeMarkers.enable},
              icons = {
                  leaf = "${nb.nodeMarkers.icons.leaf}",
                  leaf_selected = "${nb.nodeMarkers.icons.leafSelected}",
                  branch = "${nb.nodeMarkers.icons.branch}",
              },
          },

          lsp = {
              auto_attach = ${boolToString nb.lsp.autoAttach},
              preference = nil, -- TODO: convert list to lua table if not null
          },

          source_buffer = {
              follow_node = ${boolToString nb.sourceBuffer.followNode},
              highlight = ${boolToString nb.sourceBuffer.highlight},
              reorient = "${nb.sourceBuffer.reorient}",
              scrolloff = ${nilOrStr nb.sourceBuffer.scrolloff}
          },

          -- TODO: make those configurable
          icons = {
              File          = "󰈙 ",
              Module        = " ",
              Namespace     = "󰌗 ",
              Package       = " ",
              Class         = "󰌗 ",
              Method        = "󰆧 ",
              Property      = " ",
              Field         = " ",
              Constructor   = " ",
              Enum          = "󰕘",
              Interface     = "󰕘",
              Function      = "󰊕 ",
              Variable      = "󰆧 ",
              Constant      = "󰏿 ",
              String        = " ",
              Number        = "󰎠 ",
              Boolean       = "◩ ",
              Array         = "󰅪 ",
              Object        = "󰅩 ",
              Key           = "󰌋 ",
              Null          = "󰟢 ",
              EnumMember    = " ",
              Struct        = "󰌗 ",
              Event         = " ",
              Operator      = "󰆕 ",
              TypeParameter = "󰊄 ",
          },

          -- make those configurable
          use_default_mappings = true,
          mappings = {
              ["<esc>"] = actions.close(),        -- Close and cursor to original location
              ["q"] = actions.close(),

              ["j"] = actions.next_sibling(),     -- down
              ["k"] = actions.previous_sibling(), -- up

              ["h"] = actions.parent(),           -- Move to left panel
              ["l"] = actions.children(),         -- Move to right panel
              ["0"] = actions.root(),             -- Move to first panel

              ["v"] = actions.visual_name(),      -- Visual selection of name
              ["V"] = actions.visual_scope(),     -- Visual selection of scope

              ["y"] = actions.yank_name(),        -- Yank the name to system clipboard "+
              ["Y"] = actions.yank_scope(),       -- Yank the scope to system clipboard "+

              ["i"] = actions.insert_name(),      -- Insert at start of name
              ["I"] = actions.insert_scope(),     -- Insert at start of scope

              ["a"] = actions.append_name(),      -- Insert at end of name
              ["A"] = actions.append_scope(),     -- Insert at end of scope

              ["r"] = actions.rename(),           -- Rename currently focused symbol

              ["d"] = actions.delete(),           -- Delete scope

              ["f"] = actions.fold_create(),      -- Create fold of current scope
              ["F"] = actions.fold_delete(),      -- Delete fold of current scope

              ["c"] = actions.comment(),          -- Comment out current scope

              ["<enter>"] = actions.select(),     -- Goto selected symbol
              ["o"] = actions.select(),

              ["J"] = actions.move_down(),        -- Move focused node down
              ["K"] = actions.move_up(),          -- Move focused node up

              ["t"] = actions.telescope({         -- Fuzzy finder at current level.
                  layout_config = {               -- All options that can be
                      height = 0.60,              -- passed to telescope.nvim's
                      width = 0.60,               -- default can be passed here.
                      prompt_position = "top",
                      preview_width = 0.50
                  },
                  layout_strategy = "horizontal"
              }),

              ["g?"] = actions.help(),            -- Open mappings help window
          }
        }
    '';
  };
}
