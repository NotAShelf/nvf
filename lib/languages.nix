{lib}: let
  inherit (builtins) isString getAttr;
  inherit (lib.options) mkOption;
  inherit (lib.types) listOf bool str submodule attrsOf anything either nullOr uniq;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) luaInline;
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
