{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.vim;
in {
  config = {
    vim.maps = {
      # normal mode mappings
      normal =
        mkIf cfg.disableArrows {
          "<up>" = {
            action = "<nop>";

            noremap = false;
          };
          "<down>" = {
            action = "<nop>";

            noremap = false;
          };
          "<left>" = {
            action = "<nop>";
            noremap = false;
          };
          "<right>" = {
            action = "<nop>";
            noremap = false;
          };
        }
        // mkIf cfg.mapLeaderSpace {
          "<space>" = {
            action = "<nop>";
          };
        };

      # insert mode mappings
      insert = mkIf cfg.disableArrows {
        "<up>" = {
          action = "<nop>";
          noremap = false;
        };
        "<down>" = {
          action = "<nop>";
          noremap = false;
        };
        "<left>" = {
          action = "<nop>";
          noremap = false;
        };
        "<right>" = {
          action = "<nop>";
          noremap = false;
        };
      };
    };
  };
}
