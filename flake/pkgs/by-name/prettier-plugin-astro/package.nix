{
  pins,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm_11,
  pnpmConfigHook,
  zstd,
  fetchPnpmDeps,
  writableTmpDirAsHomeHook,
}: let
  pin = pins.prettier-plugin-astro;
  pnpm = pnpm_11;
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "prettier-plugin-astro";
    version = pin.version or pin.revision;

    src = fetchFromGitHub {
      inherit (pin.repository) owner repo;
      rev = finalAttrs.version;
      sha256 = pin.hash;
    };

    # Upstream still ships a lockfileVersion 6.0 pnpm-lock.yaml, which pnpm 11
    # refuses to use under --frozen-lockfile. Replace it with a pre-migrated
    # lockfile (generated via `pnpm install --lockfile-only` on pnpm 11) so
    # both the dependency fetch and the build itself see the same lockfile.
    # FIXME: this sucks
    postPatch = ''
      cp ${./pnpm-lock.yaml} pnpm-lock.yaml
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit pnpm;
      inherit (finalAttrs) pname version src postPatch;
      hash = "sha256-ODVuEvZbFDXDWUl2Bfp4inG37frUbbRM7bCQxRa2bpM=";
      fetcherVersion = 4; # https://nixos.org/manual/nixpkgs/stable/#javascript-pnpm-fetcherVersion
    };

    nativeBuildInputs = [
      nodejs
      writableTmpDirAsHomeHook
      (pnpmConfigHook.override {
        inherit pnpm;
      })
      pnpm
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
