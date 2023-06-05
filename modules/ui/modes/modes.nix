{lib, ...}:
with lib;
with builtins; {
  options.vim.ui.modes-nvim = {
    enable = mkEnableOption "modes.nvim's prismatic line decorations";

    setCursorline = mkOption {
      type = types.bool;
      description = "Set a colored cursorline on current line";
      default = false;
    };
  };
}
