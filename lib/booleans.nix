# From home-manager: https://github.com/nix-community/home-manager/blob/master/modules/lib/booleans.nix
{lib}: {
  # Converts a boolean to a yes/no string. This is used in lots of
  # configuration formats.
  yesNo = value:
    if value
    then "yes"
    else "no";
}
