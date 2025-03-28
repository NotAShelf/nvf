{
  config,
  lib,
  ...
}: let
  inherit (lib.strings) optionalString;
  inherit (lib.lists) optional;
  inherit (lib.modules) mkIf;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.binds) mkKeymap;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.terminal.toggleterm;
  lazygitMapDesc = "Open lazygit [toggleterm]";
  slidesMapDesc = "Open slides [toggleterm]";
in {
  config = mkIf cfg.enable {
    vim = {
      lazy.plugins.toggleterm-nvim = {
        package = "toggleterm-nvim";
        cmd = [
          "ToggleTerm"
          "ToggleTermSendCurrentLine"
          "ToggleTermSendVisualLines"
          "ToggleTermSendVisualSelection"
          "ToggleTermSetName"
          "ToggleTermToggleAll"
        ];
        keys =
          [
            (mkKeymap "n" cfg.mappings.open "<Cmd>execute v:count . \"ToggleTerm\"<CR>" {
              desc = "Toggle terminal";
            })
          ]
          ++ optional cfg.lazygit.enable {
            key = cfg.lazygit.mappings.open;
            mode = "n";
            desc = lazygitMapDesc;
          }
          ++ optional cfg.slides.enable {
            key = cfg.slides.mappings.open;
            mode = "n";
            desc = slidesMapDesc;
          };

        setupModule = "toggleterm";
        inherit (cfg) setupOpts;
        after =
          optionalString cfg.lazygit.enable ''
            local terminal = require 'toggleterm.terminal'
            local lazygit = terminal.Terminal:new({
              cmd = '${
              if (cfg.lazygit.package != null)
              then getExe cfg.lazygit.package
              else "lazygit"
            }',
              direction = '${cfg.lazygit.direction}',
              hidden = true,
              on_open = function(term)
                vim.cmd("startinsert!")
              end
            })

            vim.keymap.set('n', ${toLuaObject cfg.lazygit.mappings.open}, function() lazygit:toggle() end, {silent = true, noremap = true, desc = '${lazygitMapDesc}'})
          ''
          + optionalString cfg.slides.enable ''
            local terminal = require 'toggleterm.terminal'

            local file_path = vim.fn.expand("%:p")

            if file_path == "" then
              print("No file open")
              return
            end

            local slides = terminal.Terminal:new({
              cmd = '${
              if (cfg.slides.package != null)
              then getExe cfg.slides.package
              else "slides"
            } ' .. file_path,
              direction = 'float',
              hidden = true,
              close_on_exit = true,
              on_open = function(term)
                vim.cmd("startinsert!")
              end
            })

            vim.keymap.set('n', ${toLuaObject cfg.slides.mappings.open}, function() slides:toggle() end, {silent = true, noremap = true, desc = '${slidesMapDesc}'})
          '';
      };
    };
  };
}
