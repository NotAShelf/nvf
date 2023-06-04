# Helpers for converting values to lua
{lib}: rec {
  # yes? no.
  yesNo = value:
    if value
    then "yes"
    else "no";

  # Convert a null value to lua's nil
  nullString = value:
    if value == null
    then "nil"
    else "'${value}'";

  # Helper function to convert an attribute name to a Lua table key
  attrToKey = name: name;

  # Function to convert a Nix attrset to a Lua table
  attrsetToLuaTable = attrset:
    "{ "
    + (
      builtins.concatStringsSep ", "
      (builtins.attrValues (
        builtins.mapAttrs (
          name: value:
            attrToKey name + " = " + ("\"" + builtins.toJSON value + "\"")
        )
        attrset
      ))
    )
    + " }";
}
