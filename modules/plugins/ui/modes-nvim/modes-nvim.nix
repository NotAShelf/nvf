{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) listOf bool either str float;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
in {
  options.vim.ui.modes-nvim = {
    enable = mkEnableOption "prismatic line decorations for Neovim [modes.nvim]";

    setupOpts = mkPluginSetupOption "modes.nvim" {
      set_cursorline = mkOption {
        type = bool;
        default = false;
        description = ''
          Whether to enable nable cursorline initially, and disable cursorline
          for inactive windows or ignored filetypes.
        '';
      };

      line_opacity = {
        visual = mkOption {
          type = float;
          default = 0.15;
          example = 0.0;
          description = "Opacity for cursorline and number background";
        };
      };

      ignore = mkOption {
        type = listOf (either str luaInline);
        default = ["NvimTree" "TelescopePrompt" "!minifiles"];
        description = ''
          Disable modes highlights for specified filetypes or enable with
          prefix "!" if otherwise disabled.

          Can also be a function that returns a boolean value that disables modes
          highlights when `true`. Use `lib.generators.mkLuaInline` if using a Lua
          function.
        '';
      };
    };
  };
}
