{
  config,
  lib,
  ...
}: let
  inherit (builtins) toJSON;
  inherit (lib.lists) optionals;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.binds) mkBinding;
  inherit (lib.nvim.dag) entryAnywhere entryAfter;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.terminal.toggleterm;
in {
  config = mkMerge [
    (
      mkIf cfg.enable {
        vim = {
          startPlugins = [
            "toggleterm-nvim"
          ];

          maps.normal = mkBinding cfg.mappings.open "<Cmd>execute v:count . \"ToggleTerm\"<CR>" "Toggle terminal";

          luaConfigRC.toggleterm = entryAnywhere ''
            require("toggleterm").setup(${toLuaObject cfg.setupOpts})
          '';
        };
      }
    )
    (
      mkIf (cfg.enable && cfg.lazygit.enable)
      {
        vim.startPlugins = optionals (cfg.lazygit.package != null) [
          cfg.lazygit.package
        ];
        vim.luaConfigRC.toggleterm-lazygit = entryAfter ["toggleterm"] ''
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

          vim.keymap.set('n', ${toJSON cfg.lazygit.mappings.open}, function() lazygit:toggle() end, {silent = true, noremap = true, desc = 'Open lazygit [toggleterm]'})
        '';
      }
    )
  ];
}
