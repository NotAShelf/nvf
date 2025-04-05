{lib}: let
  inherit (builtins) isString getAttr;
  inherit (lib.options) mkOption;
  inherit (lib.types) listOf bool str submodule;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) luaInline;
in {
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
    options = {
      enable = mkOption {
        type = bool;
        default = true;
        description = "Whether to enable this LSP server.";
      };

      capabilities = mkOption {
        type = luaInline;
        default = mkLuaInline "capabilities";
        description = "LSP capabilitiess to pass to lspconfig";
      };

      on_attach = mkOption {
        type = luaInline;
        default = mkLuaInline "default_on_attach";
        description = "Function to execute when an LSP server attaches to a buffer";
      };

      filetypes = mkOption {
        type = listOf str;
        description = "Filetypes to auto-attach LSP in";
      };

      cmd = mkOption {
        type = listOf str;
        description = "Command used to start the LSP server";
      };

      root_markers = mkOption {
        type = listOf str;
        description = ''
          "root markers" used to determine the root directory of the workspace, and
          the filetypes associated with this LSP server.
        '';
      };
    };
  };
}
