{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.utility.nix-develop.enable = mkEnableOption "in-neovim `nix develop`, `nix shell`, and more using `nix-develop.nvim`";
}
