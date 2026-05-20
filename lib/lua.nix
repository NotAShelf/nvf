# Helpers for converting values to lua
{lib}: let
  /**
    Test whether an object is a `luaInline` value (i.e. has `_type == "lua-inline"`).

    # Type

    ```
    isLuaInline :: Any -> Bool
    ```

    # Arguments

    - `object`: Any Nix value.

    # Example

    ```nix
    isLuaInline (lib.mkLuaInline "vim.fn.getcwd()")
    => true

    isLuaInline "just a string"
    => false
    ```
  */
  isLuaInline = object: (object._type or null) == "lua-inline";

  /**
    Recursively convert a Nix value to its Lua representation as a string.

    Handles all primitive Nix types as well as lists, attribute sets,
    derivations (rendered as their store path string), and `luaInline` values
    (rendered verbatim). Null attributes are stripped from sets.

    # Type

    ```
    toLuaObject :: Any -> String
    ```

    # Arguments

    - `args`: Any Nix value to convert.

    # Example

    ```nix
    toLuaObject { a = 1; b = true; c = null; }
    => ''{["a"] = 1,\n["b"] = true}''

    toLuaObject [ "x" "y" ]
    => ''{"x",\n"y"}''
    ```
  */
  toLuaObject = args:
    {
      int = toString args;
      float = toString args;

      # escapes \ and quotes
      string = builtins.toJSON args;
      path = builtins.toJSON args;

      bool = lib.boolToString args;
      null = "nil";

      list = "{${lib.concatMapStringsSep ",\n" toLuaObject args}}";

      set =
        if lib.isDerivation args
        then ''"${args}"''
        else if isLuaInline args
        then args.expr
        else "{${
          lib.pipe args [
            (lib.filterAttrs (_: v: v != null))
            (builtins.mapAttrs (
              n: v:
                if lib.hasPrefix "@" n
                then toLuaObject v
                else "[${toLuaObject n}] = ${toLuaObject v}"
            ))
            builtins.attrValues
            (lib.concatStringsSep ",\n")
          ]
        }}";
    }
    .${
      builtins.typeOf args
    }
    or (builtins.throw "Could not convert object of type `${builtins.typeOf args}` to lua object");
in
  {
    inherit isLuaInline toLuaObject;

    /**
      Convert a list of Lua expression strings into a Lua table string.

      Each element is wrapped with `mkLuaInline` before conversion so that
      strings are treated as raw Lua rather than quoted string literals.

      # Type

      ```
      luaTable :: [String] -> String
      ```

      # Arguments

      - `x`: List of Lua expression strings.

      # Example

      ```nix
      luaTable [ "vim.fn.getcwd()" "vim.fn.expand('%')" ]
      => ''{vim.fn.getcwd(),\nvim.fn.expand('%')}''
      ```
    */
    luaTable = x: (toLuaObject (map lib.mkLuaInline x));
  }
  // lib.genAttrs [
    "nullString"
    "expToLua"
    "listToLuaTable"
    "attrsetToLuaTable"
  ] (name: builtins.throw "${name} is deprecated use toLuaObject instead")
