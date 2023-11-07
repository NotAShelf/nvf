{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption;
in {
  options.vim.dashboard.alpha = {
    enable = mkEnableOption "dashboard via alpha.nvim";
  };
}
