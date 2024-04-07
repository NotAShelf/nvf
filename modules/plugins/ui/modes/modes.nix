{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) bool str float;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.ui.modes-nvim = {
    enable = mkEnableOption "modes.nvim's prismatic line decorations";

    setupOpts = {
      setCursorline = mkOption {
        type = bool;
        description = "Set a colored cursorline on current line";
        default = false; # looks ugly, disabled by default
      };

      line_opacity = {
        visual = mkOption {
          type = float;
          description = "Set opacity for cursorline and number background";
          default = 0.0;
        };
      };

      colors = mkPluginSetupOption "modes.nvim" {
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
  };
}
