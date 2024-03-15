{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) str;
in {
  options.vim.ui.modes-nvim = {
    enable = mkEnableOption "modes.nvim's prismatic line decorations";

    setCursorline = mkOption {
      type = bool;
      description = "Set a colored cursorline on current line";
      default = false; # looks ugly, disabled by default
    };

    colors = {
      copy = mkOption {
        type = str;
        default = "#f5c359";
        description = "The #RRGGBB color code for the visual mode highlights";
      };

      delete = mkOption {
        type = str;
        default = "#c75c6a";
        description = "The #RRGGBB color code for the visual mode highlights";
      };

      insert = mkOption {
        type = str;
        default = "#78ccc5";
        description = "The #RRGGBB color code for the visual mode highlights";
      };

      visual = mkOption {
        type = str;
        default = "#9745be";
        description = "The #RRGGBB color code for the visual mode highlights";
      };
    };
  };
}
