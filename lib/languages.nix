# From home-manager: https://github.com/nix-community/home-manager/blob/master/modules/lib/booleans.nix
{lib}: let
  inherit (builtins) isString getAttr;
  inherit (lib.options) mkOption;
  inherit (lib.types) bool;
  inherit (lib.nvim.attrsets) mapListToAttrs;
in {
  # Converts a boolean to a yes/no string. This is used in lots of
  # configuration formats, and is not covered by `toLuaObject`
  toVimBool = bool:
    if bool
    then "yes"
    else "no";

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
}
