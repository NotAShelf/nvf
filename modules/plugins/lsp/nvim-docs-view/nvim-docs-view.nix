{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types mkMappingOption;
in {
  options.vim.lsp.nvim-docs-view = {
    enable = mkEnableOption "nvim-docs-view, for displaying lsp hover documentation in a side panel.";

    position = mkOption {
      type = types.enum ["left" "right" "top" "bottom"];
      default = "right";
      description = ''
        Where to open the docs view panel
      '';
    };

    height = mkOption {
      type = types.int;
      default = 10;
      description = ''
        Height of the docs view panel if the position is set to either top or bottom
      '';
    };

    width = mkOption {
      type = types.int;
      default = 60;
      description = ''
        Width of the docs view panel if the position is set to either left or right
      '';
    };

    updateMode = mkOption {
      type = types.enum ["auto" "manual"];
      default = "auto";
      description = ''
        Determines the mechanism used to update the docs view panel content.
        - If auto, the content will update upon cursor move.
        - If manual, the content will only update once :DocsViewUpdate is called
      '';
    };

    mappings = {
      viewToggle = mkMappingOption "Open or close the docs view panel" "lvt";
      viewUpdate = mkMappingOption "Manually update the docs view panel" "lvu";
    };
  };
}
