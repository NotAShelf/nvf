{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAfter;

  inherit (config.vim) treesitter;
  cfg = treesitter.context;
in {
  config = mkIf (treesitter.enable && cfg.enable) {
    vim = {
      startPlugins = ["nvim-treesitter-context"];

      # set up treesitter-context after Treesitter. The ordering
      # should not matter, but there is no harm in doing this
      luaConfigRC.treesitter-context = entryAfter ["treesitter"] ''
        require("treesitter-context").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
