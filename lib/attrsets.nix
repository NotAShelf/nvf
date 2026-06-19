{lib}: let
  inherit (builtins) listToAttrs;
in {
  /**
  Map over a list and convert the result to an attribute set.

  # Type

  ```
  mapListToAttrs :: (a -> { name :: String; value :: b }) -> [a] -> AttrSet
  ```

  # Arguments

  - `f`: Function mapping each list element to a `{ name; value }` pair.
  - `list`: The list to map over.

  # Example

  ```nix
  mapListToAttrs (x: { name = x; value = x; }) ["a" "b"]
  => { a = "a"; b = "b"; }
  ```
  */
  mapListToAttrs = f: list: listToAttrs (map f list);
}
