{
  pins,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm_9,
  pnpmConfigHook,
  fetchPnpmDeps,
  writableTmpDirAsHomeHook,
}: let
  pin = pins.prettier-plugin-astro;
  pnpm = pnpm_9;
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
      inherit pnpm;
      inherit (finalAttrs) pname version src;
      hash = "sha256-K7pIWLkIIbUKDIcysfEtcf/eVMX9ZgyFHdqcuycHCNE=";
      fetcherVersion = 3; # https://nixos.org/manual/nixpkgs/stable/#javascript-pnpm-fetcherVersion
    };

    nativeBuildInputs = [
      nodejs
      writableTmpDirAsHomeHook
      (pnpmConfigHook.overrideAttrs {
        propagatedBuildInputs = [pnpm];
      })
    ];

    buildPhase = ''
      runHook preBuild

      pnpm run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r dist/ $out
      cp -r node_modules $out

      runHook postInstall
    '';
  })
