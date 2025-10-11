{
  pins,
  pkgs,
  ...
}: let
  pin = pins.mcp-hub;
  src = pkgs.fetchFromGitHub {
    inherit (pin.repository) owner repo;
    tag = pin.version;
    sha256 = pin.hash;
  };

  inherit (pkgs) nodejs;
in
  pkgs.buildNpmPackage {
    pname = "mcp-hub";
    inherit (pin) version;
    inherit src nodejs;

    nativeBuildInputs = [nodejs];
    npmDeps = pkgs.importNpmLock {
      npmRoot = src;
    };
    inherit (pkgs.importNpmLock) npmConfigHook;
  }
