# From home-manager: https://github.com/nix-community/home-manager/blob/master/modules/lib/booleans.nix
{lib}: let
  inherit (builtins) isString getAttr;
  inherit (lib.options) mkOption;
  inherit (lib.attrsets) listToAttrs;
  inherit (lib.types) bool;
in {
  # Converts a boolean to a yes/no string. This is used in lots of
  # configuration formats.
  diagnosticsToLua = {
    lang,
    config,
    diagnosticsProviders,
  }:
    listToAttrs
    (map (v: let
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
      config);

  mkEnable = desc:
    mkOption {
      description = "Turn on ${desc} for enabled languages by default";
      type = bool;
      default = false;
    };
}
