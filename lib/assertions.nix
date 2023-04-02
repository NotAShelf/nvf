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
    mkIf
    (config.programs.neovim-flake.enable)
    {
      assertion = !config.programs.neovim.enable;
      message = "You cannot use neovim-flake together with vanilla neovim.";
    }
  ];
}
