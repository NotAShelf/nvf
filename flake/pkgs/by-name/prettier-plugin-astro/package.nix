{
  lib,
  pins,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm_11,
  pnpmConfigHook,
  fetchPnpmDeps,
  prettier,
}: let
  pin = pins.prettier-plugin-astro;
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "prettier-plugin-astro";
    version = lib.removePrefix "v" pin.version;

    src = fetchFromGitHub {
      inherit (pin.repository) owner repo;
      rev = pin.revision;
      hash = pin.hash;
    };

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pnpm_11;
      hash = "sha256-XgPnyFbA0ZjDh0uGUH1uOaMZas9QjQp8m7I2BgeBy3Q=";
      fetcherVersion = 4;
    };

    nativeBuildInputs = [
      nodejs
      pnpm_11
      (pnpmConfigHook.override {pnpm = pnpm_11;})
    ];

    buildPhase = ''
      runHook preBuild
      pnpm run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      pnpm prune --prod --ignore-scripts
      cp -r dist $out
      cp -r node_modules $out
      # prettier is a peer dependency, so pruning drops it.
      ln -s ${prettier}/lib/node_modules/prettier $out/node_modules/prettier
      runHook postInstall
    '';

    meta = {
      description = "Prettier plugin for Astro";
      homepage = "https://github.com/withastro/prettier-plugin-astro";
      license = lib.licenses.mit;
    };
  })
