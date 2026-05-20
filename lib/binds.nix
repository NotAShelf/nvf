{lib}: let
  inherit (lib.options) mkOption;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.types) nullOr str;
  inherit (lib.attrsets) isAttrs mapAttrs;

  binds = rec {
    /**
      Create a silent Lua keybinding wrapped in `mkIf` to guard against null keys.

      # Type

      ```
      mkLuaBinding :: String | Null -> String -> String -> AttrSet
      ```

      # Arguments

      - `key`: The key sequence to bind, or `null` to disable.
      - `action`: Lua expression to execute on keypress.
      - `desc`: Human-readable description of the binding.

      # Example

      ```nix
      mkLuaBinding "<leader>f" "require('telescope').find_files" "Find files"
      => { "<leader>f" = { action = "require('telescope').find_files"; desc = "Find files"; lua = true; silent = true; }; }
      ```
    */
    mkLuaBinding = key: action: desc:
      mkIf (key != null) {
        "${key}" = {
          inherit action desc;
          lua = true;
          silent = true;
        };
      };

    /**
      Create a silent expression-mode Lua keybinding wrapped in `mkIf`.

      # Type

      ```
      mkExprBinding :: String | Null -> String -> String -> AttrSet
      ```

      # Arguments

      - `key`: The key sequence to bind, or `null` to disable.
      - `action`: Lua expression evaluated as a Vim expression.
      - `desc`: Human-readable description of the binding.

      # Example

      ```nix
      mkExprBinding "<C-n>" "v:count == 0 ? 'j' : 'gj'" "Smart down"
      => { "<C-n>" = { action = "v:count == 0 ? 'j' : 'gj'"; desc = "Smart down"; lua = true; silent = true; expr = true; }; }
      ```
    */
    mkExprBinding = key: action: desc:
      mkIf (key != null) {
        "${key}" = {
          inherit action desc;
          lua = true;
          silent = true;
          expr = true;
        };
      };

    /**
      Create a silent (non-Lua) keybinding wrapped in `mkIf` to guard against null keys.

      # Type

      ```
      mkBinding :: String | Null -> String -> String -> AttrSet
      ```

      # Arguments

      - `key`: The key sequence to bind, or `null` to disable.
      - `action`: Vimscript command or mapping string to execute.
      - `desc`: Human-readable description of the binding.

      # Example

      ```nix
      mkBinding "<leader>w" ":w<CR>" "Save file"
      => { "<leader>w" = { action = ":w<CR>"; desc = "Save file"; silent = true; }; }
      ```
    */
    mkBinding = key: action: desc:
      mkIf (key != null) {
        "${key}" = {
          inherit action desc;
          silent = true;
        };
      };

    /**
      Build a nullable string NixOS option suitable for storing a keybinding value.

      # Type

      ```
      mkMappingOption :: String -> String | Null -> Option
      ```

      # Arguments

      - `description`: Documentation string for the option.
      - `default`: Default key value, or `null` for no binding.

      # Example

      ```nix
      mkMappingOption "Toggle file tree" "<leader>e"
      => mkOption { type = nullOr str; default = "<leader>e"; description = "Toggle file tree"; }
      ```
    */
    mkMappingOption = description: default:
      mkOption {
        type = nullOr str;
        inherit default description;
      };

    /**
      Merge actual mapping values with their description metadata.

      Takes two attribute sets: one mapping keys to values and another mapping
      keys to `{ description }` records. Produces an attribute set mapping
      keys to `{ value; description }` records. Nesting is handled recursively.

      # Type

      ```
      addDescriptionsToMappings :: AttrSet -> AttrSet -> AttrSet
      ```

      # Arguments

      - `actualMappings`: Attribute set of key → value pairs.
      - `mappingDefinitions`: Attribute set of key → `{ description }` pairs.

      # Example

      ```nix
      addDescriptionsToMappings { someKey = "some_value"; } { someKey = { description = "Some Description"; }; }
      => { someKey = { value = "some_value"; description = "Some Description"; }; }
      ```
    */
    addDescriptionsToMappings = actualMappings: mappingDefinitions:
      mapAttrs (name: value: let
        isNested = isAttrs value;
        returnedValue =
          if isNested
          then addDescriptionsToMappings actualMappings."${name}" mappingDefinitions."${name}"
          else {
            inherit value;
            inherit (mappingDefinitions."${name}") description;
          };
      in
        returnedValue)
      actualMappings;

    /**
      Create a non-Lua keybinding from a structured binding record produced by `mkMappingOption`.

      # Type

      ```
      mkSetBinding :: { value :: String | Null; description :: String } -> String -> AttrSet
      ```

      # Arguments

      - `binding`: Binding record with `value` (key) and `description` fields.
      - `action`: Vimscript command or mapping string to execute.

      # Example

      ```nix
      mkSetBinding { value = "<leader>w"; description = "Save file"; } ":w<CR>"
      => mkBinding "<leader>w" ":w<CR>" "Save file"
      ```
    */
    mkSetBinding = binding: action:
      mkBinding binding.value action binding.description;

    /**
      Create an expression-mode Lua keybinding from a structured binding record.

      # Type

      ```
      mkSetExprBinding :: { value :: String | Null; description :: String } -> String -> AttrSet
      ```

      # Arguments

      - `binding`: Binding record with `value` (key) and `description` fields.
      - `action`: Lua expression evaluated as a Vim expression.

      # Example

      ```nix
      mkSetExprBinding { value = "<C-n>"; description = "Smart down"; } "v:count == 0 ? 'j' : 'gj'"
      => mkExprBinding "<C-n>" "v:count == 0 ? 'j' : 'gj'" "Smart down"
      ```
    */
    mkSetExprBinding = binding: action:
      mkExprBinding binding.value action binding.description;

    /**
      Create a silent Lua keybinding from a structured binding record.

      # Type

      ```
      mkSetLuaBinding :: { value :: String | Null; description :: String } -> String -> AttrSet
      ```

      # Arguments

      - `binding`: Binding record with `value` (key) and `description` fields.
      - `action`: Lua expression to execute on keypress.

      # Example

      ```nix
      mkSetLuaBinding { value = "<leader>f"; description = "Find files"; } "require('telescope').find_files"
      => mkLuaBinding "<leader>f" "require('telescope').find_files" "Find files"
      ```
    */
    mkSetLuaBinding = binding: action:
      mkLuaBinding binding.value action binding.description;

    /**
      Apply `mkDefault` to every value in an attribute set.

      Useful for lowering the priority of a set of option defaults so they can
      be overridden by user configuration.

      # Type

      ```
      pushDownDefault :: AttrSet -> AttrSet
      ```

      # Arguments

      - `attr`: Attribute set whose values should be wrapped with `mkDefault`.

      # Example

      ```nix
      pushDownDefault { a = true; b = "hello"; }
      => { a = mkDefault true; b = mkDefault "hello"; }
      ```
    */
    pushDownDefault = attr: mapAttrs (_: mkDefault) attr;

    /**
      Build a keymap record by merging extra options with mode, key, and action fields.

      # Type

      ```
      mkKeymap :: String -> String -> String -> AttrSet -> AttrSet
      ```

      # Arguments

      - `mode`: Vim mode string (e.g. `"n"`, `"v"`, `"i"`).
      - `key`: Key sequence to bind.
      - `action`: Action to execute on keypress.
      - `opt`: Extra options merged into the resulting record.

      # Example

      ```nix
      mkKeymap "n" "<leader>w" ":w<CR>" { silent = true; }
      => { mode = "n"; key = "<leader>w"; action = ":w<CR>"; silent = true; }
      ```
    */
    mkKeymap = mode: key: action: opt: opt // {inherit mode key action;};
  };
in
  binds
