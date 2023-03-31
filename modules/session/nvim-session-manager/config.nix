{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.session.nvim-session-manager;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["nvim-session-manager"];

    vim.luaConfigRC.nvim-session-manager = nvim.dag.entryAnywhere ''
      require('session_manager').setup({})
    '';
  };
}
