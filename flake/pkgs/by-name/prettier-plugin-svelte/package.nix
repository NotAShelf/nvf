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

    npmDepsHash = "sha256-zejYnwkj6CBWOqA6LBYBEXMg0jT2vJqinBwzKdWIqpY=";

    dontNpmPrune = true;

    # Fixes error: Cannot find module 'prettier'
    postInstall = ''
      pushd "$nodeModulesPath"
      find -mindepth 1 -maxdepth 1 -type d -print0 | grep --null-data -Exv "\./(ulid|prettier)" | xargs -0 rm -rfv
      popd
    '';
  })
