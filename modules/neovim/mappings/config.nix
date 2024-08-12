{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim;
in {
  config = {
    vim.maps = mkIf cfg.disableArrows {
      "<up>" = {
        mode = ["n" "i"];
        action = "<nop>";
        noremap = false;
      };
      "<down>" = {
        mode = ["n" "i"];
        action = "<nop>";
        noremap = false;
      };
      "<left>" = {
        mode = ["n" "i"];
        action = "<nop>";
        noremap = false;
      };
      "<right>" = {
        mode = ["n" "i"];
        action = "<nop>";
        noremap = false;
      };
    };
  };
}
