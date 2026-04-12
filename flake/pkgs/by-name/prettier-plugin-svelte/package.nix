{
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
  pins,
}: let
  pin = pins.prettier-plugin-svelte;
in
  buildNpmPackage (finalAttrs: {
    pname = "prettier-plugin-svelte";
    version = pin.version or pin.revision;

    meta.mainProgram = "prettier";

    src = fetchFromGitHub {
      inherit (pin.repository) owner repo;
      rev = finalAttrs.version;
      sha256 = pin.hash;
    };

    npmDepsHash = "sha256-XVyLW0XDCvZCZxu8g1fP7fRfeU3Hz81o5FCi/i4BKQw=";

    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/bin" "$out/lib"
      cp -r node_modules "$out/lib/"
      mkdir -p "$out/lib/node_modules/prettier-plugin-svelte"
      cp -r browser.js index.d.ts package.json plugin.js plugin.js.map "$out/lib/node_modules/prettier-plugin-svelte/"

      makeWrapper "${nodejs}/bin/node" "$out/bin/prettier" \
        --add-flags "$out/lib/node_modules/prettier/bin/prettier.cjs" \
        --set NODE_PATH "$out/lib/node_modules"

      runHook postInstall
    '';
  })
