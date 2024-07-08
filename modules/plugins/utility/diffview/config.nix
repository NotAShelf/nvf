{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.diffview-nvim;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "diffview-nvim"
      "plenary-nvim"
    ];
  };
}
