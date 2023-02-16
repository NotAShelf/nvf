{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.comments.comment-nvim;
in {
  options.vim.comments.comment-nvim = {
    enable = mkEnableOption "comment-nvim";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [
      "comment-nvim"
    ];

    vim.luaConfigRC.comment-nvim = nvim.dag.entryAnywhere ''
      require('Comment').setup()
    '';
  };
}
