{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.vim;
in {
  assertions = mkMerge [
    {
      assertion = cfg.kommentary.enable;
      message = "Kommentary has been deprecated in favor";
    }
  ];
}
