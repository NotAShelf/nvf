{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.utility.vim-wakatime;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      "vim-wakatime"
    ];
  };
}
