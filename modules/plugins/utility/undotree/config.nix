{ ... }:
{
  vim.lazy.plugins.undotree = {
    package = "undotree";
    cmd = [
      "UndotreeToggle"
      "UndotreeShow"
      "UndotreeHide"
      "UndotreePersistUndo"
      "UndotreeFocus"
    ];
  };
}
