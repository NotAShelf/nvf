{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
  inherit (lib.generators) mkLuaInline;
  mkMappingOption = config.vim.lib.mkMappingOption "Harpoon";
in {
  options.vim.navigation.harpoon = {
    mappings = {
      markFile = mkMappingOption "Mark file" "<leader>a";
      listMarks = mkMappingOption "List marked files" "<C-e>";
      file1 = mkMappingOption "Go to marked file 1" "<C-j>";
      file2 = mkMappingOption "Go to marked file 2" "<C-k>";
      file3 = mkMappingOption "Go to marked file 3" "<C-l>";
      file4 = mkMappingOption "Go to marked file 4" "<C-;>";
    };

    enable = mkEnableOption "Quick bookmarks on keybinds [Harpoon]";

    setupOpts = mkPluginSetupOption "Harpoon" {
      defaults = {
        save_on_toggle = mkOption {
          type = bool;
          default = false;
          description = ''
            Any time the ui menu is closed then we will save the
            state back to the backing list, not to the fs
          '';
        };
        sync_on_ui_close = mkOption {
          type = bool;
          default = false;
          description = ''
            Any time the ui menu is closed then the state of the
            list will be sync'd back to the fs
          '';
        };
        key = mkOption {
          type = luaInline;
          default = mkLuaInline ''
            function()
              return vim.uv.cwd()
            end
          '';
          description = ''
            How the out list key is looked up. This can be useful
            when using worktrees and using git remote instead of file path
          '';
        };
      };
    };
  };
}
