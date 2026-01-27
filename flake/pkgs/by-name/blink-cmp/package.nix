{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  writeShellScriptBin,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "blink-cmp";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "Saghen";
    repo = "blink.cmp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JjlcPj7v9J+v1SDBYIub6jFEslLhZGHmsipV1atUAFo=";
  };

  forceShare = [
    "man"
    "info"
  ];

  postInstall = ''
    cp -r {lua,plugin} "$out"

    mkdir -p "$out/doc"
    cp 'doc/'*'.txt' "$out/doc/"

    mkdir -p "$out/target"
    mv "$out/lib" "$out/target/release"
  '';

  cargoHash = "sha256-Qdt8O7IGj2HySb1jxsv3m33ZxJg96Ckw26oTEEyQjfs=";

  nativeBuildInputs = [
    (writeShellScriptBin "git" "exit 1")
  ];

  env = {
    RUSTC_BOOTSTRAP = true;

    # Those are the Linker args used by upstream. Without those, the build fails.
    # See:
    #  <https://github.com/saghen/blink.cmp/blob/main/.cargo/config.toml#L1C1-L11C2>
    RUSTFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-C link-arg=-undefined -C link-arg=dynamic_lookup";
  };

  meta = {
    description = "Performant, batteries-included completion plugin for Neovim";
    homepage = "https://github.com/saghen/blink.cmp";
    changelog = "https://github.com/Saghen/blink.cmp/blob/v${finalAttrs.version}/CHANGELOG.md";
  };
})
