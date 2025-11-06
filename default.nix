(import (
    let
      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
      inherit (lock.nodes.flake-compat.locked) url rev narHash;
    in
      builtins.fetchTarball {
        url = "${url}/archive/${rev}.tar.gz";
        sha256 = narHash;
      }
  ) {
    src = ./.;
    copySourceTreeToStore = false;
    useBuiltinsFetchTree = true;
  })
.defaultNix
