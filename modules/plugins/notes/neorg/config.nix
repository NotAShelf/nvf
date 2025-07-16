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
          require('neorg').setup(${toLuaObject cfg.setupOpts})
        '';
      };
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.norgPackage cfg.treesitter.norgMetaPackage];
    })
  ]);
}
