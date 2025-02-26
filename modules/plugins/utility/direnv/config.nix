{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.direnv;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["direnv-vim"];
  };
}
