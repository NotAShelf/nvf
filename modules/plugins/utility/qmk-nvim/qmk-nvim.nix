{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) attrsOf nullOr enum lines str;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.qmk-nvim = {
    enable = mkEnableOption "QMK and ZMK keymaps in nvim";

    setupOpts = mkPluginSetupOption "qmk.nvim" {
      name = mkOption {
        type = nullOr str;
        default = null;
        description = "The name of the layout";
      };

      layout = mkOption {
        type = nullOr lines;
        default = null;
        description = ''
          The keyboard key layout
          see <https://github.com/codethread/qmk.nvim?tab=readme-ov-file#Layout> for more details
        '';
      };

      variant = mkOption {
        type = enum ["qmk" "zmk"];
        default = "qmk";
        description = "Chooses the expected hardware target";
      };

      comment_preview = {
        position = mkOption {
          type = enum ["top" "bottom" "inside" "none"];
          default = "top";
          description = "Controls the position of the preview";
        };

        keymap_overrides = mkOption {
          type = attrsOf str;
          default = {};
          description = ''
            Key codes to text replacements
            see <https://github.com/codethread/qmk.nvim/blob/main/lua/qmk/config/key_map.lua> for more details
          '';
        };
      };
    };
  };
}
