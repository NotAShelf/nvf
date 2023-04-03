{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.ui.modes-nvim;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "modes-nvim"
    ];

    vim.luaConfigRC.modes-nvim = nvim.dag.entryAnywhere ''
      require('modes').setup()
    '';
  };
}
