{lib}: {
  imports = lib.concatLists [
    # Configuration options for Neovim UI
    (lib.filesystem.listFilesRecursive ./ui)
  ];
}
