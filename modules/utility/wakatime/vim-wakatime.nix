{
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; {
  options.vim.utility.vim-wakatime = {
    enable = mkEnableOption "vim-wakatime: live code statistics";

    cli-package = mkOption {
      type = with types; nullOr package;
      default = pkgs.wakatime;
      description = "The package that should be used for wakatime-cli. Set as null to use the default path in `$XDG_DATA_HOME`";
    };
  };
}
