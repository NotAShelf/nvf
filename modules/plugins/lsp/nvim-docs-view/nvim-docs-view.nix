{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types mkMappingOption mkRenamedOptionModule;
in {
  options.vim.lsp.nvim-docs-view = {
    enable = mkEnableOption "nvim-docs-view, for displaying lsp hover documentation in a side panel.";

    imports = let
      renamedSetupOption = oldPath: newPath:
        mkRenamedOptionModule
        (["vim" "lsp" "nvim-docs-view"] ++ oldPath)
        (["vim" "lsp" "nvim-docs-view" "setupOpts"] ++ newPath);
    in [
      (renamedSetupOption ["position"] ["position"])
      (renamedSetupOption ["width"] ["width"])
      (renamedSetupOption ["height"] ["height"])
      (renamedSetupOption ["updateMode"] ["update_mode"])
    ];

    setupOpts = lib.nvim.types.mkPluginSetupOption "nvim-docs-view" {
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

      update_mode = mkOption {
        type = types.enum ["auto" "manual"];
        default = "auto";
        description = ''
          Determines the mechanism used to update the docs view panel content.
          - If auto, the content will update upon cursor move.
          - If manual, the content will only update once :DocsViewUpdate is called
        '';
      };
    };

    mappings = {
      viewToggle = mkMappingOption "Open or close the docs view panel" "lvt";
      viewUpdate = mkMappingOption "Manually update the docs view panel" "lvu";
    };
  };
}
