{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  languageOpts = {
    columnAt = mkOption {
      type = types.nullOr types.int;
      default = 80;
    };
  };
in {
  options.vim.ui.smartcolumn = {
    enable = mkEnableOption "Enable smartcolumn line length indicator";

    showColumnAt = mkOption {
      type = types.nullOr types.int;
      default = 120;
      description = "The position at which the column will be displayed. Set to null to disable";
    };

    disabledFiletypes = mkOption {
      type = types.listOf types.str;
      default = ["help" "text" "markdown" "NvimTree" "alpha"];
      description = "The filetypes smartcolumn will be disabled for.";
    };

    /*
    languages = mkOption {
      default = {};
      description = "Language specific configuration.";
      type = with types;
        attrsOf (submodule {
          options = languageOpts;
        });
    };
    */
  };
}
