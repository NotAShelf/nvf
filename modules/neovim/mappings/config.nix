{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.trivial) pipe;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists) flatten;

  legacyMapModes = {
    normal = ["n"];
    insert = ["i"];
    select = ["s"];
    visual = ["v"];
    terminal = ["t"];
    normalVisualOp = ["n" "v" "o"];
    visualOnly = ["n" "x"];
    operator = ["o"];
    insertCommand = ["i" "c"];
    lang = ["l"];
    command = ["c"];
  };

  cfg = config.vim;
in {
  config = {
    vim.keymaps = mkMerge [
      (
        mkIf cfg.disableArrows [
          {
            key = "<up>";
            mode = ["n" "i"];
            action = "<nop>";
            noremap = false;
          }
          {
            key = "<down>";
            mode = ["n" "i"];
            action = "<nop>";
            noremap = false;
          }
          {
            key = "<left>";
            mode = ["n" "i"];
            action = "<nop>";
            noremap = false;
          }
          {
            key = "<right>";
            mode = ["n" "i"];
            action = "<nop>";
            noremap = false;
          }
        ]
      )
      (
        pipe cfg.maps
        [
          (mapAttrsToList (
            oldMode: keybinds:
              mapAttrsToList (
                key: bind:
                  bind
                  // {
                    inherit key;
                    mode = legacyMapModes.${oldMode};
                  }
              )
              keybinds
          ))
          flatten
        ]
      )
    ];
  };
}
