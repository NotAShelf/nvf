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

  expToLua = exp:
    if builtins.isList exp
    then listToLuaTable exp
    else if builtins.isAttrs exp
    then attrsetToLuaTable exp
    else ("\"" + builtins.toJSON exp + "\"");

  listToLuaTable = list:
    "{ " + (builtins.concatStringsSep ", " (map expToLua list)) + " }";

  attrsetToLuaTable = attrset:
    "{ "
    + (
      builtins.concatStringsSep ", "
      (
        lib.mapAttrsToList (
          name: value:
            name
            + " = "
            + (expToLua value)
        )
        attrset
      )
    )
    + " }";
}
