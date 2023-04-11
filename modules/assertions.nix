{
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
      message = "Kommentary has been deprecated in favor of comments-nvim";
    }
    mkIf
    (config.programs.neovim-flake.enable)
    {
      assertion = !config.programs.neovim.enable;
      message = "You cannot use `programs.neovim-flake.enable` with `programs.neovim.enable`";
    }
  ];
}
