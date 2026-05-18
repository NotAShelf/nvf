{
  stdenv,
  nodejs,
  gitMinimal,
  pnpm_9,
  pnpmConfigHook,
  fetchPnpmDeps,
  pins,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
}: let
  pin = pins.prettier-plugin-pug;
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "prettier-plugin-pug";
    version = pin.version or pin.revision;

    patches = [
      ./0001-fix-don-t-touch-git-state-while-building.patch
    ];

    src = fetchFromGitHub {
      inherit (pin.repository) owner repo;
      rev = finalAttrs.version;
      sha256 = pin.hash;
    };

    pnpmDeps = fetchPnpmDeps {
      pnpm = pnpm_9;
      inherit (finalAttrs) pname version src;
      hash = "sha256-NBetqPzn99W0mvv2niL9bJ3iOexOB4VAIGA7CmUn00M=";
      fetcherVersion = 3;
    };

    nativeBuildInputs = [
      nodejs
      gitMinimal
      writableTmpDirAsHomeHook
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

      cp -r dist/ $out
      cp -r node_modules $out

      runHook postInstall
    '';
  })
