{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  cfg = config.vim.utility.mkdir;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mkdir-nvim"];
  };
}
