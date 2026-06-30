{
  stdenv,
  nodejs,
  gitMinimal,
  pnpm_11,
  pnpmConfigHook,
  zstd,
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
      pnpm = pnpm_11;
      inherit (finalAttrs) pname version src;
      hash = "sha256-vpbevN2jgde4qsoRvWMEvkXBYDTeZEggpY0FlAAJomo=";
      fetcherVersion = 3;
    };

    nativeBuildInputs = [
      nodejs
      gitMinimal
      writableTmpDirAsHomeHook
      (pnpmConfigHook.override {
        pnpm = pnpm_11;
      })
      pnpm_11
      zstd
    ];

    buildPhase = ''
      runHook preBuild
      pnpm run build
      runHook postBuild
    '';

    preInstall = ''
      cp -r dist/ $out
      cp -r node_modules $out
    '';
  })
