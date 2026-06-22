{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool int str listOf enum;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (config.vim.lib) mkMappingOption;
in {
  options.vim.utility.csvview = {
    enable = mkEnableOption "View CSV/TSV files as aligned tables [csvview.nvim]";

    autoEnable =
      mkEnableOption ''
        Automatically enable the CSV view when opening CSV/TSV files.
      ''
      // {default = true;};

    mappings = {
      toggle = mkMappingOption "Toggle CSV view [csvview]" "<leader>tc";
    };

    # Note: These defaults are a subset of the csvview default configuration, as defined in
    # [https://github.com/hat0uma/csvview.nvim/blob/5c22774c3ecc7f8883af5d143b366e45b1f0875d/README.md?plain=1#L97]
    # which I think users would most likely want to modify
    setupOpts = mkPluginSetupOption "csvview.nvim" {
      parser = {
        async_chunksize = mkOption {
          type = int;
          default = 50;
          description = "Number of lines processed per asynchronous parsing cycle. If the UI freezes, try reducing this value.";
        };

        comments = mkOption {
          type = listOf str;
          default = [];
          description = ''
            List of comment prefixes. Lines starting with one of these are
            treated as comments and excluded from table rendering, e.g.
            `["#" "//"]`.
          '';
        };
      };

      view = {
        min_column_width = mkOption {
          type = int;
          default = 5;
          description = "Minimum width of a column";
        };

        spacing = mkOption {
          type = int;
          default = 2;
          description = "Spacing between columns";
        };

        display_mode = mkOption {
          type = enum ["highlight" "border"];
          default = "highlight";
          description = ''
            Display method for the column delimiter.

            - `highlight`: highlight the delimiter character.
            - `border`: render the delimiter as a vertical border.
          '';
        };

        sticky_header = {
          enabled = mkOption {
            type = bool;
            default = true;
            description = "Keep the header row visible at the top while scrolling";
          };
        };
      };
    };
  };
}
