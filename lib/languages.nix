# From home-manager: https://github.com/nix-community/home-manager/blob/master/modules/lib/booleans.nix
{lib}: {
  # Converts a boolean to a yes/no string. This is used in lots of
  # configuration formats.
  diagnosticsToLua = {
    lang,
    config,
    diagnostics,
  }:
    lib.listToAttrs
    (map (v: let
        type =
          if builtins.isString v
          then v
          else builtins.getAttr v.type;
        package =
          if builtins.isString v
          then diagnostics.${type}.package
          else v.package;
      in {
        name = "${lang}-diagnostics-${type}";
        value = diagnostics.${type}.nullConfig package;
      })
      config);
}
