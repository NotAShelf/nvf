{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.vim;
in {
  config = {
    assertions = mkMerge [
      {
        assertion = cfg.kommentary.enable;
        message = "Kommentary has been deprecated in favor of comments-nvim";
      }
      {
        assertion = cfg.utility.colorizer.enable;
        message = "config.utility.colorizer has been renamed to config.utility.ccc";
      }
      mkIf
      (config.programs.neovim-flake.enable)
      {
        assertion = !config.programs.neovim.enable;
        message = "You cannot use `programs.neovim-flake.enable` with `programs.neovim.enable`";
      }
    ];
  };
}
