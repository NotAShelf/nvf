{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  cfg = config.vim.utility.nix-develop;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["nix-develop-nvim"];
  };
}
