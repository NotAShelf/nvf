{
  lib,
  config,
  ...
}: let
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkOption;
  inherit (lib.types) bool nullOr str;
in {
  options.vim.utility.surround = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "nvim-surround: add/change/delete surrounding delimiter pairs with ease. Note that the default mappings deviate from upstreeam to avoid conflicts with nvim-leap.";
    };
    useVendoredKeybindings = mkOption {
      type = bool;
      default = true;
      description = "Use alternative set of keybindings that avoids conflicts with other popular plugins, e.g. nvim-leap";
    };
    mappings = {
      insert = mkOption {
        type = nullOr str;
        default = "<C-g>z";
        description = "Add surround character around the cursor";
      };
      insertLine = mkOption {
        type = nullOr str;
        default = "<C-g>Z";
        description = "Add surround character around the cursor on new lines";
      };
      normal = mkOption {
        type = nullOr str;
        default = "gz";
        description = "Surround motion with character";
      };
      normalCur = mkOption {
        type = nullOr str;
        default = "gZ";
        description = "Surround motion with character on new lines";
      };
      normalLine = mkOption {
        type = nullOr str;
        default = "gzz";
        description = "Surround line with character";
      };
      normalCurLine = mkOption {
        type = nullOr str;
        default = "gZZ";
        description = "Surround line with character on new lines";
      };
      visual = mkOption {
        type = nullOr str;
        default = "gz";
        description = "Surround selection with character";
      };
      visualLine = mkOption {
        type = nullOr str;
        default = "gZ";
        description = "Surround selection with character on new lines";
      };
      delete = mkOption {
        type = nullOr str;
        default = "gzd";
        description = "Delete surrounding character";
      };
      change = mkOption {
        type = nullOr str;
        default = "gzr";
        description = "Change surrounding character";
      };
    };
  };
  config.vim.utility.surround = let
    cfg = config.vim.utility.surround;
  in {
    mappings = mkIf (! cfg.useVendoredKeybindings) (mkDefault {
      insert = null;
      insertLine = null;
      normal = null;
      normalCur = null;
      normalLine = null;
      normalCurLine = null;
      visual = null;
      visualLine = null;
      delete = null;
      change = null;
    });
  };
}
