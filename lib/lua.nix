# Helpers for converting values to lua
{lib}: let
  inherit (builtins) head throw typeOf isList isAttrs isBool isInt isString isPath isFloat toJSON;
  inherit (lib.attrsets) mapAttrsToList filterAttrs hasAttr;
  inherit (lib.strings) concatStringsSep concatMapStringsSep stringToCharacters;
  inherit (lib.trivial) boolToString warn;
in rec {
  # Convert a null value to lua's nil
  nullString = value:
    if value == null
    then "nil"
    else "'${value}'";

  expToLua = exp: builtins.warn "expToLua is deprecated, please use toLuaObject instead" (toLuaObject exp);
  listToLuaTable = exp: builtins.warn "listToLuaTable is deprecated, please use toLuaObject instead" (toLuaObject exp);
  attrsetToLuaTable = exp: builtins.warn "attrsetToLuaTable is deprecated, please use toLuaObject instead" (toLuaObject exp);
  luaTable = exp: builtins.warn "luaTable is deprecated, please use toLuaObject instead" (toLuaObject exp);

  # Check if the given object is a Lua inline object.
  # isLuaInline :: AttrSet -> Bool
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
