{lib, ...}: let
  inherit (lib.lists) concatLists;
  inherit (lib.filesystem) listFilesRecursive;
in {
  imports = concatLists [
    # Configuration options for Neovim UI
    (listFilesRecursive ./ui)

    # vim.diagnostics
    [./diagnostics.nix]
  ];
}
