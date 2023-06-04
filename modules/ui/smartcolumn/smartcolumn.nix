{lib, ...}:
with lib;
with builtins; {
  options.vim.ui.smartcolumn = {
    enable = mkEnableOption "Enable Smartcolumn line length indicator";

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

    columnAt = {
      # TODO: the current implementation only allows for options such as { ruby = "120", java = "120" }
      # whereas the lua config would allow { ruby = "120", java = { "180", "200"} }, this needs to be fixed in the custom lib
      languages = lib.mkOption {
        description = "The position at which smart column should be displayed for each individual buffer type";
        type = lib.types.submodule {
          freeformType = with lib.types; attrsOf int;
        };
      };
    };
  };
}
