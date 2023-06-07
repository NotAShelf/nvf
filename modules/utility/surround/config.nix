{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.utility.surround;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      "nvim-surround"
    ];

    vim.luaConfigRC.surround = nvim.dag.entryAnywhere ''
      require('nvim-surround').setup()
    '';
  };
}
