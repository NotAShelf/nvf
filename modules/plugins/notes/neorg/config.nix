{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.binds) pushDownDefault;

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
          "neorg-telescope"
        ];

        lazy.plugins.neorg = {
          package = "neorg";
          setupModule = "neorg";
          inherit (cfg) setupOpts;

          ft = ["norg"];
          cmd = ["Neorg"];
        };

        binds.whichKey.register = pushDownDefault {
          "<leader>o" = "+Notes";
        };
      };
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.norgPackage cfg.treesitter.norgMetaPackage];
    })
  ]);
}
