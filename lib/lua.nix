# Helpers for converting values to lua
{lib}: let
  inherit (lib) mapAttrsToList filterAttrs concatStringsSep concatMapStringsSep stringToCharacters boolToString;
  inherit (builtins) hasAttr head;
in rec {
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
  # Convert a list of lua expressions to a lua table. The difference to listToLuaTable is that the elements here are expected to be lua expressions already, whereas listToLuaTable converts from nix types to lua first
  luaTable = items: ''{${builtins.concatStringsSep "," items}}'';

  toLuaObject = args:
    if builtins.isAttrs args
    then
      if hasAttr "__raw" args
      then args.__raw
      else if hasAttr "__empty" args
      then "{ }"
      else
        "{"
        + (concatStringsSep ","
          (mapAttrsToList
            (n: v:
              if head (stringToCharacters n) == "@"
              then toLuaObject v
              else "[${toLuaObject n}] = " + (toLuaObject v))
            (filterAttrs
              (
                _: v:
                  (v != null) && (toLuaObject v != "{}")
              )
              args)))
        + "}"
    else if builtins.isList args
    then "{" + concatMapStringsSep "," toLuaObject args + "}"
    else if builtins.isString args
    then
      # This should be enough!
      builtins.toJSON args
    else if builtins.isPath args
    then builtins.toJSON (toString args)
    else if builtins.isBool args
    then "${boolToString args}"
    else if builtins.isFloat args
    then "${toString args}"
    else if builtins.isInt args
    then "${toString args}"
    else if (args != null)
    then "nil"
    else "";
}
