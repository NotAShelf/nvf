{lib}: let
  inherit (builtins) isString getAttr;
  inherit (lib.options) mkOption;
  inherit (lib.types) listOf bool str submodule attrsOf anything either nullOr uniq;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) luaInline;
in {
  # TODO: remove
  /**
  Convert a list of diagnostic provider entries to a DAG-compatible attribute set.

  Accepts either plain strings (provider type names) or attrsets with `type`
  and `package` fields, and produces named entries suitable for merging into
  a null-ls/none-ls DAG.

  # Type

  ```
  diagnosticsToLua :: { lang :: String; config :: [String | { type :: String; package :: Derivation }]; diagnosticsProviders :: AttrSet } -> AttrSet
  ```

  # Arguments

  - `lang`: Language identifier used to prefix generated entry names.
  - `config`: List of provider names (strings) or `{ type; package }` records.
  - `diagnosticsProviders`: Attribute set mapping provider type names to `{ package; nullConfig }` records.

  # Example

  ```nix
  diagnosticsToLua { lang = "python"; config = [ "flake8" ]; diagnosticsProviders = { flake8 = { package = pkgs.python3Packages.flake8; nullConfig = pkg: "..."; }; }; }
  => { "python-diagnostics-flake8" = "..."; }
  ```
  */
  diagnosticsToLua = {
    lang,
    config,
    diagnosticsProviders,
  }:
    mapListToAttrs
    (v: let
      type =
        if isString v
        then v
        else getAttr v.type;
      package =
        if isString v
        then diagnosticsProviders.${type}.package
        else v.package;
    in {
      name = "${lang}-diagnostics-${type}";
      value = diagnosticsProviders.${type}.nullConfig package;
    })
    config;

  /**
  Build a boolean NixOS option that enables a language feature for all enabled languages.

  # Type

  ```
  mkEnable :: String -> Option
  ```

  # Arguments

  - `desc`: Short description of the feature being enabled (interpolated into the option description).

  # Example

  ```nix
  mkEnable "LSP support"
  => mkOption { default = false; type = bool; description = "Turn on LSP support for enabled languages by default"; }
  ```
  */
  mkEnable = desc:
    mkOption {
      default = false;
      type = bool;
      description = "Turn on ${desc} for enabled languages by default";
    };

  /**
  A freeform submodule type for LSP server options.

  Provides a structured set of well-known LSP configuration fields
  (`enable`, `capabilities`, `on_attach`, `filetypes`, `cmd`, `root_markers`)
  while allowing arbitrary extra fields via `freeformType`.

  # Type

  ```
  lspOptions :: SubmoduleType
  ```

  # Example

  ```nix
  vim.languages.rust.lsp.options = {
    enable = true;
    root_markers = [ "Cargo.toml" ];
  };
  ```
  */
  lspOptions = submodule {
    freeformType = attrsOf anything;
    options = {
      enable = mkOption {
        type = bool;
        default = true;
        description = "Whether to enable this LSP server.";
      };

      capabilities = mkOption {
        type = nullOr (either luaInline (attrsOf anything));
        default = null;
        description = "LSP capabilities to pass to LSP server configuration";
      };

      on_attach = mkOption {
        type = nullOr luaInline;
        default = null;
        description = "Function to execute when an LSP server attaches to a buffer";
      };

      filetypes = mkOption {
        type = nullOr (listOf str);
        default = null;
        description = "Filetypes to auto-attach LSP server in";
      };

      cmd = mkOption {
        type = nullOr (either luaInline (uniq (listOf str)));
        default = null;
        description = "Command used to start the LSP server";
      };

      root_markers = mkOption {
        type = nullOr (listOf str);
        default = null;
        description = ''
          "root markers" used to determine the root directory of the workspace, and
          the filetypes associated with this LSP server.
        '';
      };
    };
  };
}
