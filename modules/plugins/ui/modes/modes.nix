{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.vim.ui.modes-nvim = {
    enable = mkEnableOption "modes.nvim's prismatic line decorations";

    setCursorline = mkOption {
      type = types.bool;
      description = "Set a colored cursorline on current line";
      default = false; # looks ugly, disabled by default
    };

    colors = {
      copy = mkOption {
        type = types.str;
        description = "The #RRGGBB color code for the visual mode highlights";
        default = "#f5c359";
      };
      delete = mkOption {
        type = types.str;
        description = "The #RRGGBB color code for the visual mode highlights";
        default = "#c75c6a";
      };
      insert = mkOption {
        type = types.str;
        description = "The #RRGGBB color code for the visual mode highlights";
        default = "#78ccc5";
      };
      visual = mkOption {
        type = types.str;
        description = "The #RRGGBB color code for the visual mode highlights";
        default = "#9745be";
      };
    };
  };
}
