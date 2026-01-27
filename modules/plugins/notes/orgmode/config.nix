{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.binds) pushDownDefault;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.notes.orgmode;
in {
  config = mkIf cfg.enable (mkMerge [
    {
      vim = {
        startPlugins = ["orgmode"];

        binds.whichKey.register = pushDownDefault {
          "<leader>o" = "+Notes";
        };

        pluginRC.orgmode = entryAnywhere ''
          -- Treesitter configuration
          require('nvim-treesitter.config').setup {

            -- If TS highlights are not enabled at all, or disabled via `disable` prop,
            -- highlighting will fallback to default Vim syntax highlighting
            highlight = {
              enable = true,
              -- Required for spellcheck, some LaTex highlights and
              -- code block highlights that do not have ts grammar
              additional_vim_regex_highlighting = {'org'},
            },
          }

          require('orgmode').setup(${toLuaObject cfg.setupOpts})
        '';
      };
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;

      vim.treesitter.grammars = [cfg.treesitter.orgPackage];
    })
  ]);
}
