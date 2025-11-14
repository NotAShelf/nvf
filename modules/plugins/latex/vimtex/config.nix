{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  # inherit (lib.nvim.dag) entryAnywhere;
  # inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.latex.vimtex;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["vimtex"];

    # vim.pluginRC.vimtex = entryAnywhere ''
    #   -- Description of each option can be found in https://github.com/lervag/vimtex
    #   -- Current nvf options are minimal, contribute your needed options
    #   -- require("vimtex").setup(${toLuaObject cfg.setupOpts})
    # '';
  };
}
