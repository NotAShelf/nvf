{lib}: let
  inherit (builtins) isString getAttr;
  inherit (lib.options) mkOption;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.types) listOf bool str submodule attrsOf anything either nullOr oneOf enum;
  inherit (lib.attrsets) attrNames;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) luaInline;
  inherit (lib.lists) isList;
  inherit (lib) genAttrs recursiveUpdate;
in {
  # TODO: remove
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

  mkEnable = desc:
    mkOption {
      default = false;
      type = bool;
      description = "Turn on ${desc} for enabled languages by default";
    };

  # resolveLspOptions
  # servers: AttrsOf lspOptions
  # selected: AttrsOf lspOptions | List of string keys from servers
  # Returns: AttrsOf lspOptions
  resolveLspOptions = {
    servers,
    selected,
  }:
    if isList selected
    then genAttrs selected (name: servers.${name})
    else selected;

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
        description = "LSP capabilitiess to pass to lspconfig";
      };

      on_attach = mkOption {
        type = nullOr luaInline;
        default = null;
        description = "Function to execute when an LSP server attaches to a buffer";
      };

      filetypes = mkOption {
        type = nullOr (listOf str);
        default = null;
        description = "Filetypes to auto-attach LSP in";
      };

      cmd = mkOption {
        type = nullOr (listOf str);
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

  mkLspOption = {servers, ...} @ args: let
    serverNames = attrNames servers;
    defaultAttrs = {
      type = oneOf [
        (attrsOf lib.nvim.languages.lspOptions)
        (listOf (enum serverNames))
      ];
      description = ''
        Either a full set of selected LSP options as an attribute set,
        or a list of server names from: ${concatStringsSep ", " serverNames}.
      '';
      default = {};
      example = {
        clangd = {
          filetypes = ["c"];
          root_markers = ["CMakeLists.txt"];
        };
      };
    };
    cleanedArgs = removeAttrs args ["servers"];
  in
    mkOption (recursiveUpdate defaultAttrs cleanedArgs);
}
