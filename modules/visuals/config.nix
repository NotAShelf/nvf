{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkMerge nvim optionalString boolToString mkBinding;

  cfg = config.vim.visuals;
in {
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.indentBlankline.enable {
      vim.startPlugins = ["indent-blankline"];
      vim.luaConfigRC.indent-blankline = nvim.dag.entryAnywhere ''
        -- highlight error: https://github.com/lukas-reineke/indent-blankline.nvim/issues/59
        -- vim.wo.colorcolumn = "99999"
        vim.opt.list = true

        ${optionalString (cfg.indentBlankline.eolChar != null) ''
          vim.opt.listchars:append({ eol = "${cfg.indentBlankline.eolChar}" })
        ''}
        ${optionalString (cfg.indentBlankline.fillChar != null) ''
          vim.opt.listchars:append({ space = "${cfg.indentBlankline.fillChar}" })
        ''}

        require("ibl").setup {
          enabled = true,
          debounce = ${toString cfg.indentBlankline.debounce},
          indent = { char = "${cfg.indentBlankline.indent.char}" },

          viewport_buffer = {
            min = ${toString cfg.indentBlankline.viewportBuffer.min},
            max = ${toString cfg.indentBlankline.viewportBuffer.max},
          },

          scope = {
            enabled = ${boolToString cfg.indentBlankline.scope.enabled},
            show_end = ${boolToString cfg.indentBlankline.scope.showEndOfLine}
          },
        }
      '';
    })

    (mkIf cfg.cursorline.enable {
      vim.startPlugins = ["nvim-cursorline"];
      vim.luaConfigRC.cursorline = nvim.dag.entryAnywhere ''
        require('nvim-cursorline').setup {
          cursorline = {
            timeout = ${toString cfg.cursorline.lineTimeout},
            number = ${boolToString (!cfg.cursorline.lineNumbersOnly)},
          }
        }
      '';
    })

    (mkIf cfg.nvimWebDevicons.enable {
      vim.startPlugins = ["nvim-web-devicons"];
    })

    (mkIf cfg.scrollBar.enable {
      vim.startPlugins = ["scrollbar-nvim"];
      vim.luaConfigRC.scrollBar = nvim.dag.entryAnywhere ''
        require('scrollbar').setup{
            excluded_filetypes = {
              'prompt',
              'TelescopePrompt',
              'noice',
              'NvimTree',
              'alpha',
              'code-action-menu-menu',
              'code-action-menu-warning-message',
              'notify',
              'Navbuddy'
            },
          }
      '';
    })

    (mkIf cfg.smoothScroll.enable {
      vim.startPlugins = ["cinnamon-nvim"];
      vim.luaConfigRC.smoothScroll = nvim.dag.entryAnywhere ''
        require('cinnamon').setup()
      '';
    })

    (mkIf cfg.cellularAutomaton.enable {
      vim.startPlugins = ["cellular-automaton"];

      vim.maps.normal = mkBinding cfg.cellularAutomaton.mappings.makeItRain "<cmd>CellularAutomaton make_it_rain<CR>" "Make it rain";

      vim.luaConfigRC.cellularAUtomaton = nvim.dag.entryAnywhere ''
        local config = {
              fps = 50,
              name = 'slide',
            }

            -- init function is invoked only once at the start
            -- config.init = function (grid)
            --
            -- end

            -- update function
            config.update = function (grid)
            for i = 1, #grid do
              local prev = grid[i][#(grid[i])]
                for j = 1, #(grid[i]) do
                  grid[i][j], prev = prev, grid[i][j]
                end
              end
              return true
            end

            require("cellular-automaton").register_animation(config)
      '';
    })

    (mkIf cfg.fidget-nvim.enable {
      vim.startPlugins = ["fidget-nvim"];
      vim.luaConfigRC.fidget-nvim = nvim.dag.entryAnywhere ''
        require"fidget".setup{
          align = {
            bottom = ${boolToString cfg.fidget-nvim.align.bottom},
            right = ${boolToString cfg.fidget-nvim.align.right},
          },
          window = {
            blend = 0,
          },
        }
      '';
    })

    (mkIf cfg.highlight-undo.enable {
      vim.startPlugins = ["highlight-undo"];
      vim.luaConfigRC.fidget-nvim = nvim.dag.entryAnywhere ''
        require('highlight-undo').setup({
          duration = ${toString cfg.highlight-undo.duration},
          highlight_for_count = ${boolToString cfg.highlight-undo.highlightForCount},
          undo = {
            hlgroup = ${cfg.highlight-undo.undo.hlGroup},
            mode = 'n',
            lhs = 'u',
            map = 'undo',
            opts = {}
          },

          redo = {
            hlgroup = ${cfg.highlight-undo.redo.hlGroup},
            mode = 'n',
            lhs = '<C-r>',
            map = 'redo',
            opts = {}
          },
        })
      '';
    })
  ]);
}
