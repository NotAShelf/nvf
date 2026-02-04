{
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm_9,
  pnpmConfigHook,
  fetchPnpmDeps,
  pins,
}: let
  pin = pins.prettier-plugin-astro;
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "prettier-plugin-astro";
    version = pin.version or pin.revision;

    src = fetchFromGitHub {
      inherit (pin.repository) owner repo;
      rev = finalAttrs.version;
      sha256 = pin.hash;
    };

    pnpmDeps = fetchPnpmDeps {
      pnpm = pnpm_9;
      inherit (finalAttrs) pname src;
      fetcherVersion = 2;
      hash = "sha256-K7pIWLkIIbUKDIcysfEtcf/eVMX9ZgyFHdqcuycHCNE=";
    };

    nativeBuildInputs = [
      nodejs
      (pnpmConfigHook.overrideAttrs {
        propagatedBuildInputs = [pnpm_9];
      })
    ];

    buildPhase = ''
      runHook preBuild

      pnpm run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      # mkdir -p $out/dist
      cp -r dist/ $out
      cp -r node_modules $out

      runHook postInstall
    '';
  })
