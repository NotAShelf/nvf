{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim;
  cfg = config.vim.visuals.fidget-nvim;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["fidget-nvim"];

    vim.luaConfigRC.fidget-nvim = nvim.dag.entryAnywhere ''
      require'fidget'.setup(${nvim.lua.toLuaObject cfg.setupOpts})
    '';
  };
}
