{
  lib,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  cfg = config.vim.lazy;
in {
  config.vim = mkIf cfg.enable {
    startPlugins = ["lz-n"];

    # optPlugins =
  };
}
