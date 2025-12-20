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
            (mkKeymap ["n" "t"] cfg.mappings.open "<Cmd>execute v:count . \"ToggleTerm\"<CR>" {
              desc = "Toggle terminal";
            })
          ]
          ++ optional cfg.lazygit.enable {
            key = cfg.lazygit.mappings.open;
            mode = "n";
            desc = lazygitMapDesc;
          };

        setupModule = "toggleterm";
        inherit (cfg) setupOpts;
        after = optionalString cfg.lazygit.enable ''
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
        '';
      };
    };
  };
}
