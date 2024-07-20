{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.visuals.fidget-nvim;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["fidget-nvim"];

    vim.pluginRC.fidget-nvim = entryAnywhere ''
      require'fidget'.setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
