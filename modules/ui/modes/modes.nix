{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) str;
in {
  options.vim.ui.modes-nvim = {
    enable = mkEnableOption "prismatic line decorations [modes.nvim]";
    setCursorline = mkEnableOption "colored cursorline on current line";
    colors = {
      copy = mkOption {
        type = str;
        description = "The #RRGGBB color code for the visual mode highlights";
        default = "#f5c359";
      };

      delete = mkOption {
        type = str;
        description = "The #RRGGBB color code for the visual mode highlights";
        default = "#c75c6a";
      };

      insert = mkOption {
        type = str;
        description = "The #RRGGBB color code for the visual mode highlights";
        default = "#78ccc5";
      };

      visual = mkOption {
        type = str;
        description = "The #RRGGBB color code for the visual mode highlights";
        default = "#9745be";
      };
    };
  };
}
