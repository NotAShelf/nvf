{
  writeShellScriptBin,
  makeDesktopItem,
  symlinkJoin,
  html,
}: let
  helpScript = writeShellScriptBin "nvf-help" ''
    set -euo pipefail

    if [[ ! -v BROWSER || -z $BROWSER ]]; then
      for candidate in xdg-open open w3m; do
        BROWSER="$(type -P $candidate || true)"
        if [[ -x $BROWSER ]]; then
          break;
        fi
      done
    fi

    if [[ ! -v BROWSER || -z $BROWSER ]]; then
      echo "$0: unable to start a web browser; please set \$BROWSER"
      exit 1
    else
      exec "$BROWSER" "${html}/share/doc/nvf/index.xhtml"
    fi
  '';

  desktopItem = makeDesktopItem {
    name = "nvf-manual";
    desktopName = "nvf Manual";
    genericName = "View nvf documentation in a web browser";
    icon = "nix-snowflake";
    exec = "${helpScript}/bin/nvf-help";
    categories = ["System"];
  };
in
  symlinkJoin {
    name = "nvf-help";
    paths = [
      helpScript
      desktopItem
    ];
  }
