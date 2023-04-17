{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.autocomplete;
  builtSources =
    concatMapStringsSep "\n" (x: "{ name = '${x}'},") cfg.sources;
in {
  options.vim = {
    autocomplete = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "enable autocomplete";
      };

      type = mkOption {
        type = types.enum ["nvim-cmp"];
        default = "nvim-cmp";
        description = "Set the autocomplete plugin. Options: [nvim-cmp]";
      };

      sources = mkOption {
        description = "List of source names for nvim-cmp";
        type = with types; listOf str;
        default = [];
      };
    };
  };
}
