_: let
  inherit (builtins) listToAttrs;
in {
  mapListToAttrs = f: list: listToAttrs (map f list);
}
