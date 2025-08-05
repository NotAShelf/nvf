{
  lib,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.undotree;
in {
  config = mkIf cfg.enable {
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
  };
}
