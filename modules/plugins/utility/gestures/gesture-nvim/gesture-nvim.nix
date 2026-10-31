{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  mkMappingOption = config.vim.lib.mkMappingOption "gesture.nvim";
in {
  options.vim.gestures.gesture-nvim = {
    enable = mkEnableOption "gesture-nvim: mouse gestures";

    mappings = {
      draw = mkMappingOption "Start drawing" "<LeftDrag>";
      finish = mkMappingOption "Finish drawing" "<LeftRelease>";
    };
  };
}
