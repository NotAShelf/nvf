{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) nullOr package;
in {
  options.vim.utility.vim-wakatime = {
    enable = mkEnableOption ''
      automatic time tracking and metrics generated from your programming activity [vim-wakatime]
    '';

    cli-package = mkOption {
      type = nullOr package;
      default = pkgs.wakatime-cli;
      example = null;
      description = ''
        The package that should be used for wakatime-cli.
        Set as null to use the default path in {env}`$XDG_DATA_HOME`
      '';
    };
  };
}
