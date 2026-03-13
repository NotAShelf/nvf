{
  config,
  lib,
  ...
}: let
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
}
