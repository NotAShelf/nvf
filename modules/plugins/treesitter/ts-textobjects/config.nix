{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAfter;

  inherit (config.vim) treesitter;
  cfg = treesitter.textobjects;
in {
  config = mkIf (treesitter.enable && cfg.enable) {
    vim = {
      startPlugins = ["nvim-treesitter-textobjects"];

      # set up treesitter-textobjects after Treesitter, whose config we're adding to.
      pluginRC.treesitter-textobjects = entryAfter ["treesitter"] ''
        require("nvim-treesitter.config").setup({textobjects = ${toLuaObject cfg.setupOpts}})
      '';
    };
  };
}
