# Stolen from <https://github.com/NixOS/nixpkgs/pull/459753>
# because <nixpkgs> is slower than your mom
{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  pkg-config,
  libsecret,
  stdenv,
}:
buildNpmPackage (finalAttrs: {
  pname = "some-sass-language-server";
  version = "2.3.8";

  src = fetchFromGitHub {
    owner = "wkillerud";
    repo = "some-sass";
    tag = "some-sass-language-server@${finalAttrs.version}";
    hash = "sha256-jmpkZReeVuf10juWMy7QO/q1Sm7kye3NTpMCeB8kG48=";
  };

  npmDepsHash = "sha256-sSumbDqiztUuTs+amYv83I6odbrIOOawXeJxdF2xkA4=";

  env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
  npmInstallFlags = ["--ignore-scripts"];

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [pkg-config];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [libsecret];

  buildPhase = ''
    runHook preBuild

    npm run build --workspace=packages/vscode-css-languageservice
    npm run build --workspace=packages/language-services
    npm run build:production --workspace=packages/language-server

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    dir=$out/lib/node_modules/some-sass-language-server
    mkdir -p $dir $out/bin
    cp -r packages/language-server/{dist,bin,package.json} $dir/
    ln -s $dir/bin/some-sass-language-server $out/bin/some-sass-language-server

    runHook postInstall
  '';

  meta = {
    description = "Language server with advanced feature support for Scss and Sass files";
    homepage = "https://wkillerud.github.io/some-sass/";
    changelog = "https://github.com/wkillerud/some-sass/releases/tag/some-sass-language-server@${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "some-sass-language-server";
  };
})
