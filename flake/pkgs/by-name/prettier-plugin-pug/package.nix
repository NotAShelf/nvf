{
  lib,
  pins,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm_12,
  pnpmConfigHook,
  fetchPnpmDeps,
  prettier,
}: let
  pnpm' = pnpm_12;
  pin = pins.prettier-plugin-pug;
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "prettier-plugin-pug";
    inherit (pin) version;

    src = fetchFromGitHub {
      inherit (pin.repository) owner repo;
      rev = pin.revision;
      hash = pin.hash;
    };

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pnpm';
      hash = "sha256-XuHinYGsG9Roujmt8uJaDbbfKYfTa/XPAi7itFskbX0=";
      fetcherVersion = 4;
    };

    nativeBuildInputs = [
      nodejs
      pnpm'
      (pnpmConfigHook.override {pnpm = pnpm';})
    ];

    # The upstream `build` script runs `git clean` first.
    buildPhase = ''
      runHook preBuild
      pnpm run build:code
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      # `pnpm prune` on pnpm 12 re-verifies every lockfile entry against the
      # registry regardless of `trustLockfile`, so reinstall production
      # dependencies instead, the same way pnpmConfigHook installs them.
      rm -rf node_modules
      pnpm_config_trust_lockfile=true pnpm install --offline --ignore-scripts --frozen-lockfile --prod

      cp -r dist $out
      cp -r node_modules $out
      # prettier is a peer dependency, so it is not installed with --prod.
      ln -s ${prettier}/lib/node_modules/prettier $out/node_modules/prettier
      runHook postInstall
    '';

    meta = {
      description = "Prettier plugin for Pug";
      homepage = "https://github.com/prettier/plugin-pug";
      license = lib.licenses.mit;
    };
  })
