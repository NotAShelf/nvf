{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.utility.diffview-nvim;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      "diffview-nvim"
      "plenary-nvim"
    ];

    vim.luaConfigRC.diffview-nvim =
      nvim.dag.entryAnywhere ''
      '';
  };
}
