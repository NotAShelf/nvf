{lib}: {
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

  mkEnable = desc:
    lib.mkOption {
      description = "Turn on ${desc} for enabled languages by default";
      type = lib.types.bool;
      default = false;
    };
}
