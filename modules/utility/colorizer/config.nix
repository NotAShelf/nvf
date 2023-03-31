{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.utility.colorizer;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      "colorizer"
    ];
  };
}
