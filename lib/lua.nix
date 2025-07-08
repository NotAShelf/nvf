# Helpers for converting values to lua
{lib}: let
  inherit (builtins) hasAttr head throw typeOf isList isAttrs isBool isInt isString isPath isFloat toJSON;
  inherit (lib.attrsets) mapAttrsToList filterAttrs;
  inherit (lib.strings) concatStringsSep concatMapStringsSep stringToCharacters;
  inherit (lib.trivial) boolToString warn;
in rec {
  # Convert a null value to lua's nil
  nullString = value:
    if value == null
    then "nil"
    else "'${value}'";

  # convert an expression to lua
  expToLua = exp:
    if isList exp
    then listToLuaTable exp # if list, convert to lua table
    else if isAttrs exp
    then attrsetToLuaTable exp # if attrs, convert to table
    else if isBool exp
    then boolToString exp # if bool, convert to string
    else if isInt exp
    then toString exp # if int, convert to string
    else if exp == null
    then "nil"
    else (toJSON exp); # otherwise jsonify the value and print as is

  # convert list to a lua table
  listToLuaTable = list:
    "{ " + (concatStringsSep ", " (map expToLua list)) + " }";

  # convert attrset to a lua table
  attrsetToLuaTable = attrset:
    "{ "
    + (
      concatStringsSep ", "
      (
        mapAttrsToList (
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
  luaTable = items: ''{${concatStringsSep "," items}}'';

  isLuaInline = object: (object._type or null) == "lua-inline";

  toLuaObject = args:
    if isAttrs args
    then
      if isLuaInline args
      then args.expr
      else if hasAttr "__empty" args
      then
        warn ''
          Using `__empty` to define an empty lua table is deprecated. Use an empty attrset instead.
        '' "{ }"
      else
        "{"
        + (concatStringsSep ","
          (mapAttrsToList
            (n: v:
              if head (stringToCharacters n) == "@"
              then toLuaObject v
              else "[${toLuaObject n}] = " + (toLuaObject v))
            (filterAttrs
              (_: v: v != null)
              args)))
        + "}"
    else if isList args
    then "{" + concatMapStringsSep "," toLuaObject args + "}"
    else if isString args
    then
      # This should be enough!
      toJSON args
    else if isPath args
    then toJSON (toString args)
    else if isBool args
    then "${boolToString args}"
    else if isFloat args
    then "${toString args}"
    else if isInt args
    then "${toString args}"
    else if (args == null)
    then "nil"
    else throw "could not convert object of type `${typeOf args}` to lua object";
}
