{
  buildNpmPackage,
  fetchFromGitHub,
  pins,
}: let
  pin = pins.prettier-plugin-svelte;
in
  buildNpmPackage (finalAttrs: {
    pname = "prettier-plugin-svelte";
    version = pin.version or pin.revision;

    src = fetchFromGitHub {
      inherit (pin.repository) owner repo;
      rev = finalAttrs.version;
      sha256 = pin.hash;
    };

    npmDepsHash = "sha256-XVyLW0XDCvZCZxu8g1fP7fRfeU3Hz81o5FCi/i4BKQw=";
  })
