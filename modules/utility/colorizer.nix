{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.utility.colorizer;
in {
  options.vim.utility.colorizer = {
    enable = mkEnableOption "ccc color picker for neovim";
  };

  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      "colorizer"
    ];

    vim.configRC.ccc =
      nvim.dag.entryAnywhere ''
      '';
  };
}
