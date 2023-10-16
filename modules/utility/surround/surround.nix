{lib, ...}:
with lib;
with builtins; {
  options.vim.utility.surround = {
    enable = mkEnableOption "nvim-surround: add/change/delete surrounding delimiter pairs with ease";
    mappings = {
      insert = mkOption {
        type = types.nullOr types.str;
        default = "<C-g>s";
        description = "Add surround character around the cursor";
      };
      insertLine = mkOption {
        type = types.nullOr types.str;
        default = "<C-g>S";
        description = "Add surround character around the cursor on new lines";
      };
      normal = mkOption {
        type = types.nullOr types.str;
        default = "ys";
        description = "Surround motion with character";
      };
      normalCur = mkOption {
        type = types.nullOr types.str;
        default = "yss";
        description = "Surround motion with character on new lines";
      };
      normalLine = mkOption {
        type = types.nullOr types.str;
        default = "yS";
        description = "Surround line with character";
      };
      normalCurLine = mkOption {
        type = types.nullOr types.str;
        default = "ySS";
        description = "Surround line with character on new lines";
      };
      visual = mkOption {
        type = types.nullOr types.str;
        default = "S";
        description = "Surround selection with character";
      };
      visualLine = mkOption {
        type = types.nullOr types.str;
        default = "gS";
        description = "Surround selection with character on new lines";
      };
      delete = mkOption {
        type = types.nullOr types.str;
        default = "ds";
        description = "Delete surrounding character";
      };
      change = mkOption {
        type = types.nullOr types.str;
        default = "cs";
        description = "Change surrounding character";
      };
    };
  };
}
