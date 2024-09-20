{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.trivial) boolToString;
  inherit (lib.nvim.binds) mkBinding;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.visuals;
in {
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.indentBlankline.enable {
      vim.startPlugins = ["indent-blankline"];
      vim.pluginRC.indent-blankline = entryAnywhere ''
        require("ibl").setup(${toLuaObject cfg.indentBlankline.setupOpts})
      '';
    })

    (mkIf cfg.cursorline.enable {
      vim.startPlugins = ["nvim-cursorline"];
      vim.pluginRC.cursorline = entryAnywhere ''
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
      vim.pluginRC.scrollBar = entryAnywhere ''
        require('scrollbar').setup{
            excluded_filetypes = {
              'prompt',
              'TelescopePrompt',
              'noice',
              'NvimTree',
              'alpha',
              'notify',
              'Navbuddy'
            },
          }
      '';
    })

    (mkIf cfg.smoothScroll.enable {
      vim.startPlugins = ["cinnamon-nvim"];
      vim.pluginRC.smoothScroll = entryAnywhere ''
        require('cinnamon').setup()
      '';
    })

    (mkIf cfg.cellularAutomaton.enable {
      vim.startPlugins = ["cellular-automaton"];

      vim.maps.normal = mkBinding cfg.cellularAutomaton.mappings.makeItRain "<cmd>CellularAutomaton make_it_rain<CR>" "Make it rain";

      vim.pluginRC.cellularAUtomaton = entryAnywhere ''
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

    (mkIf cfg.highlight-undo.enable {
      vim.startPlugins = ["highlight-undo"];
      vim.pluginRC.highlight-undo = entryAnywhere ''
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
