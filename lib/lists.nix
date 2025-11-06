{lib, ...}: let
  inherit (lib.lists) elem all;
in {
  /*
  Checks if all values are present in the list.

  Type:
    listContainsValues :: { list :: [a], values :: [a] } -> Bool

  Arguments:
    list - A list of elements.
    values - A list of values to check for presence in the list.

  Returns:
    True if all values are present in the list, otherwise False.

  Example:
    ```nix
    listContainsValues { list = [1 2 3]; values = [2 3]; }
    => True

    listContainsValues { list = [1 2 3]; values = [2 4]; }
    => False
    ```
  */
  listContainsValues = {
    list,
    values,
  }: let
    # Check if all values are present in the list
    containsValue = value: elem value list;
  in
    all containsValue values;
}
