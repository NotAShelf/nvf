{lib}: let
  inherit (builtins) isInt isBool toJSON;
in rec {
  # yes? no.
  yesNo = value:
    if value
    then "yes"
    else "no";

  # convert a boolean to a vim compliant boolean string
  mkVimBool = val:
    if val
    then "1"
    else "0";

  # convert a literal value to a vim compliant value
  valToVim = val:
    if (isInt val)
    then (builtins.toString val)
    else
      (
        if (isBool val)
        then (mkVimBool val)
        else (toJSON val)
      );
}
