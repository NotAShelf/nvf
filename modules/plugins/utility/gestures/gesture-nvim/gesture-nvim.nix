{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (config.vim.lib) mkMappingOption;
in {
  options.vim.gestures.gesture-nvim = {
    enable = mkEnableOption "gesture-nvim: mouse gestures";

    mappings = {
      draw = mkMappingOption "Start drawing [gesture.nvim]" "<LeftDrag>";
      finish = mkMappingOption "Finish drawing [gesture.nvim]" "<LeftRelease>";
    };
  };
}
