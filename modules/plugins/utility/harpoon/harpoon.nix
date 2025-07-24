{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
  inherit (lib.generators) mkLuaInline;
in {
  options.vim.navigation.harpoon = {
    mappings = {
      markFile = mkMappingOption config.vim.enableNvfKeymaps "Mark file [Harpoon]" "<leader>a";
      listMarks = mkMappingOption config.vim.enableNvfKeymaps "List marked files [Harpoon]" "<C-e>";
      file1 = mkMappingOption config.vim.enableNvfKeymaps "Go to marked file 1 [Harpoon]" "<C-j>";
      file2 = mkMappingOption config.vim.enableNvfKeymaps "Go to marked file 2 [Harpoon]" "<C-k>";
      file3 = mkMappingOption config.vim.enableNvfKeymaps "Go to marked file 3 [Harpoon]" "<C-l>";
      file4 = mkMappingOption config.vim.enableNvfKeymaps "Go to marked file 4 [Harpoon]" "<C-;>";
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
