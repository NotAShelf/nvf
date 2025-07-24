{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  options.vim.gestures.gesture-nvim = {
    enable = mkEnableOption "gesture-nvim: mouse gestures";

    mappings = {
      draw = mkMappingOption config.vim.enableNvfKeymaps "Start drawing [gesture.nvim]" "<LeftDrag>";
      finish = mkMappingOption config.vim.enableNvfKeymaps "Finish drawing [gesture.nvim]" "<LeftRelease>";
    };
  };
}
