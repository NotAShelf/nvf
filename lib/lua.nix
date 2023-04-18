# Helpers for converting values to lua
{lib}: {
  yesNo = value:
    if value
    then "yes"
    else "no";

  nullString = value:
    if value == null
    then "nil"
    else "'${value}'";
}
