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
            require("toggleterm").setup({
              open_mapping = null,
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
