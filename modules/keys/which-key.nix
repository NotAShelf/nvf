{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.keys;
in {
  options.vim.keys = {
    enable = mkEnableOption "key binding plugins";

    whichKey = {
      enable = mkEnableOption "which-key menu";
    };
  };

  config = mkIf (cfg.enable && cfg.whichKey.enable) {
    vim.startPlugins = ["which-key"];

    vim.luaConfigRC.whichkey = nvim.dag.entryAnywhere ''local wk = require("which-key").setup {}'';
  };
}
