{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.binds) pushDownDefault;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.notes.neorg;
in {
  config = mkIf cfg.enable (mkMerge [
    {
      vim = {
        startPlugins = [
          "lua-utils-nvim"
          "nui-nvim"
          "nvim-nio"
          "pathlib-nvim"
          "plenary-nvim"
          "neorg"
          "neorg-telescope"
        ];

        binds.whichKey.register = pushDownDefault {
          "<leader>o" = "+Notes";
        };

        pluginRC.neorg = entryAnywhere ''
          -- Treesitter configuration
          require('nvim-treesitter.configs').setup {

            -- If TS highlights are not enabled at all, or disabled via `disable` prop,
            -- highlighting will fallback to default Vim syntax highlighting
            highlight = {
              enable = true,
              -- Required for spellcheck, some LaTex highlights and
              -- code block highlights that do not have ts grammar
              additional_vim_regex_highlighting = {'neorg'},
            },
          }

          require('neorg').setup{
          ${cfg.setupOpts}
          }

          vim.wo.conceallevel = 2
        '';
      };
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;

      vim.treesitter.grammars = [cfg.treesitter.norgPackage];
    })
  ]);
}
