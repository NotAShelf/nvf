{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.utility.direnv.enable = mkEnableOption "syncing nvim shell environment with direnv's using `direnv.vim`";
}
