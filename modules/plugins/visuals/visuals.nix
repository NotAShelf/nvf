{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) int bool str;

  cfg = config.vim.visuals;
in {
  options.vim.visuals = {
    enable = mkEnableOption "Visual enhancements.";

    highlight-undo = {
      enable = mkEnableOption "highlight undo [highlight-undo]";

      highlightForCount = mkOption {
        type = bool;
        default = true;
        description = ''
          Enable support for highlighting when a <count> is provided before the key
          If set to false it will only highlight when the mapping is not prefixed with a <count>
        '';
      };

      duration = mkOption {
        type = int;
        description = "Duration of highlight";
        default = 500;
      };

      undo = {
        hlGroup = mkOption {
          type = str;
          description = "Highlight group for undo";
          default = "HighlightUndo";
        };
      };

      redo = {
        hlGroup = mkOption {
          type = str;
          description = "Highlight group for redo";
          default = "HighlightUndo";
        };
      };
    };
  };
}
