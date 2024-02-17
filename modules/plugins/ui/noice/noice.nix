{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption;
in {
  options.vim.ui.noice = {
    enable = mkEnableOption "noice-nvim UI modification library";
  };
}
