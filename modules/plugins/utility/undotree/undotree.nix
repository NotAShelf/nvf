{ lib, ... }:
let
  inherit (lib.options) mkEnableOption;
in
{
  options.vim.undotree = {
    enable = mkEnableOption "undo history visualizer for Vim [undotree]";
  };
}
