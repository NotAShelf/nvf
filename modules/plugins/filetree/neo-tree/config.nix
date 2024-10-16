{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.filetree.neo-tree;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        # dependencies
        "plenary-nvim" # commons library
        "image-nvim" # optional for image previews
        "nui-nvim" # ui library
        # neotree
        "neo-tree-nvim"
      ];

      visuals.nvimWebDevicons.enable = true;

      pluginRC.neo-tree = entryAnywhere ''
        require("neo-tree").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
