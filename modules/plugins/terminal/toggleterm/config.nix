{
  config,
  lib,
  ...
}: let
  inherit (builtins) toJSON;
  inherit (lib.strings) optionalString;
  inherit (lib.modules) mkIf;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.binds) mkLznBinding;

  cfg = config.vim.terminal.toggleterm;
in {
  config = mkIf cfg.enable {
    vim = {
      lazy.plugins = [
        {
          package = "toggleterm-nvim";
          cmd = ["ToggleTerm" "ToggleTermSendCurrentLine" "ToggleTermSendVisualLines" "ToggleTermSendVisualSelection" "ToggleTermSetName" "ToggleTermToggleAll"];
          keys = [
            (mkLznBinding ["n"] cfg.mappings.open "<Cmd>execute v:count . \"ToggleTerm\"<CR>" "Toggle terminal")
            {key = cfg.lazygit.mappings.open;}
          ];

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

            vim.keymap.set('n', ${toJSON cfg.lazygit.mappings.open}, function() lazygit:toggle() end, {silent = true, noremap = true, desc = 'Open lazygit [toggleterm]'})
          '';
        }
      ];
    };
  };
}
