{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.notes.quarto-nvim;
in {
  config = mkIf cfg.enable (mkMerge [
    {
      vim = {
        startPlugins = [ "otter-nvim" "quarto-nvim" ];

        pluginRC.quarto-nvim = entryAnywhere ''
          require('quarto').setup(${toLuaObject cfg.setupOpts})
        '';
      };
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.quartoPackage];
    })
  ]);
}
