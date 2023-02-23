{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.visuals;
in {
  options.vim.visuals = {
    enable = mkOption {
      type = types.bool;
      description = "visual enhancements";
    };

    nvimWebDevicons.enable = mkOption {
      type = types.bool;
      description = "enable dev icons. required for certain plugins [nvim-web-devicons]";
    };

    lspkind.enable = mkOption {
      type = types.bool;
      description = "enable vscode-like pictograms for lsp [lspkind]";
    };

    scrollBar.enable = mkOption {
      type = types.bool;
      description = "enable scrollbar [scrollbar.nvim]";
    };

    smoothScroll.enable = mkOption {
      type = types.bool;
      description = "enable smooth scrolling [cinnamon-nvim]";
    };

    cellularAutomaton.enable = mkOption {
      type = types.bool;
      description = "enable cellular automaton [cellular-automaton]";
      default = false;
    };

    cursorWordline = {
      enable = mkOption {
        type = types.bool;
        description = "enable word and delayed line highlight [nvim-cursorline]";
      };

      lineTimeout = mkOption {
        type = types.int;
        description = "time in milliseconds for cursorline to appear";
      };
    };

    fidget-nvim.enable = {
      type = types.bool;
      description = "a UI for nvim-lsp's progress handler";
      default = true;
    };

    indentBlankline = {
      enable = mkOption {
        type = types.bool;
        description = "enable indentation guides [indent-blankline]";
      };

      listChar = mkOption {
        type = types.str;
        description = "Character for indentation line";
      };

      fillChar = mkOption {
        type = types.str;
        description = "Character to fill indents";
      };

      eolChar = mkOption {
        type = types.str;
        description = "Character at end of line";
      };

      showCurrContext = mkOption {
        type = types.bool;
        description = "Highlight current context from treesitter";
      };
    };
  };

  config =
    mkIf cfg.enable
    {
      vim.startPlugins = [
        (
          if cfg.nvimWebDevicons.enable
          then "nvim-web-devicons"
          else null
        )
        (
          if cfg.lspkind.enable
          then "lspkind"
          else null
        )
        (
          if cfg.cursorWordline.enable
          then "nvim-cursorline"
          else null
        )
        (
          if cfg.indentBlankline.enable
          then "indent-blankline"
          else null
        )
        (
          if cfg.scrollBar.enable
          then "scrollbar-nvim"
          else null
        )
        (
          if cfg.smoothScroll.enable
          then "cinnamon-nvim"
          else null
        )
        (
          if cfg.cellularAutomaton.enable
          then "cellular-automaton"
          else null
        )
        (
          if cfg.fidget-nvim.enable
          then "fidget-nvim"
          else null
        )
      ];

      vim.luaConfigRC.visuals = nvim.dag.entryAnywhere ''
        ${
          if cfg.lspkind.enable
          then "require'lspkind'.init()"
          else ""
        }
        ${
          if cfg.indentBlankline.enable
          then ''
            -- highlight error: https://github.com/lukas-reineke/indent-blankline.nvim/issues/59
            vim.wo.colorcolumn = "99999"
            vim.opt.list = true


            ${
              if cfg.indentBlankline.eolChar == ""
              then ""
              else ''vim.opt.listchars:append({ eol = "${cfg.indentBlankline.eolChar}" })''
            }

            ${
              if cfg.indentBlankline.fillChar == ""
              then ""
              else ''vim.opt.listchars:append({ space = "${cfg.indentBlankline.fillChar}"})''
            }

            require("indent_blankline").setup {
              char = "${cfg.indentBlankline.listChar}",
              show_current_context = ${boolToString cfg.indentBlankline.showCurrContext},
              show_end_of_line = true,
            }
          ''
          else ""
        }

        ${
          if cfg.cursorWordline.enable
          then "vim.g.cursorline_timeout = ${toString cfg.cursorWordline.lineTimeout}"
          else ""
        }

        ${
          if cfg.scrollBar.enable
          then "require('scrollbar').setup{
            excluded_filetypes = {
              'prompt',
              'TelescopePrompt',
              'noice',
              'NvimTree',
              'alpha'
            },
          }"
          else ""
        }
        ${
          if cfg.smoothScroll.enable
          then "require('cinnamon').setup()"
          else ""
        }
        ${
          if cfg.cellularAutomaton.enable
          then ''
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

            vim.keymap.set("n", "<leader>fml", "<cmd>CellularAutomaton make_it_rain<CR>")
          ''
          else ""
        }
        ${
          if cfg.fidget-nvim.enable
          then ''
            -- TODO: make those configurable
            require"fidget".setup{
              text = {
                spinner = "pipe",         -- animation shown when tasks are ongoing
                done = "✔",               -- character shown when all tasks are complete
                commenced = "Started",    -- message shown when task starts
                completed = "Completed",  -- message shown when task completes
              },
              align = {
                bottom = true,            -- align fidgets along bottom edge of buffer
                right = true,             -- align fidgets along right edge of buffer
              },
              timer = {
                spinner_rate = 125,       -- frame rate of spinner animation, in ms
                fidget_decay = 2000,      -- how long to keep around empty fidget, in ms
                task_decay = 1000,        -- how long to keep around completed task, in ms
              },
              window = {
                relative = "win",         -- where to anchor, either "win" or "editor"
                blend = 100,              -- &winblend for the window
                zindex = nil,             -- the zindex value for the window
                border = "none",          -- style of border for the fidget window
              },
          ''
          else ""
        }
      '';
    };
}
