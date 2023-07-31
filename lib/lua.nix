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

  # convert an expression to lua

  expToLua = exp:
    if builtins.isList exp
    then listToLuaTable exp # if list, convert to lua table
    else if builtins.isAttrs exp
    then attrsetToLuaTable exp # if attrs, convert to table
    else if builtins.isBool exp
    then lib.boolToString exp # if bool, convert to string
    else if builtins.isInt exp
    then builtins.toString exp # if int, convert to string
    else (builtins.toJSON exp); # otherwise jsonify the value and print as is

  # convert list to a lua table
  listToLuaTable = list:
    "{ " + (builtins.concatStringsSep ", " (map expToLua list)) + " }";

  # convert attrset to a lua table
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
