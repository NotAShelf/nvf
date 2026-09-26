{
  lib,
  pins,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
  fetchPnpmDeps,
  prettier,
}: let
  pnpm' = pnpm_10;
  pin = pins.prettier-plugin-svelte;
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "prettier-plugin-svelte";
    version = lib.removePrefix "prettier-plugin-svelte@" pin.version;

    src = fetchFromGitHub {
      inherit (pin.repository) owner repo;
      rev = pin.revision;
      hash = pin.hash;
    };

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pnpm';
      hash = "sha256-pPPATBjdVrkilllk9Xc6J2WWpERwmq6l0W0wUrWq7II=";
      fetcherVersion = 4;
    };

    nativeBuildInputs = [
      nodejs
      pnpm'
      (pnpmConfigHook.override {pnpm = pnpm';})
    ];

    buildPhase = ''
      runHook preBuild
      pnpm run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      install -Dm644 -t $out plugin.js
      # The plugin bundles everything except its peer dependencies, prettier
      # and svelte. `svelte/compiler` resolves to a self-contained bundle, so
      # the svelte package can be copied without its own dependencies.
      mkdir $out/node_modules
      cp -rL node_modules/svelte $out/node_modules/svelte
      ln -s ${prettier}/lib/node_modules/prettier $out/node_modules/prettier

      runHook postInstall
    '';

    meta = {
      description = "Prettier plugin for Svelte";
      homepage = "https://github.com/sveltejs/prettier-plugin-svelte";
      license = lib.licenses.mit;
    };
  })
