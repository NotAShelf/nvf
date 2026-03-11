{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  rust-jemalloc-sys,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "blink-cmp";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "Saghen";
    repo = "blink.cmp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GgodXdWpQoF2z1g1/WvnSpfuhskw0aMcOoyZM5l66q8=";
  };

  forceShare = [
    "man"
    "info"
  ];

  # Tries to call git
  preBuild = ''
    rm build.rs
  '';

  postInstall = ''
    cp -r {lua,plugin} "$out"

    mkdir -p "$out/doc"
    cp 'doc/'*'.txt' "$out/doc/"

    mkdir -p "$out/target"
    mv "$out/lib" "$out/target/release"
  '';

  # From the blink.cmp flake
  buildInputs = lib.optionals stdenv.hostPlatform.isAarch64 [rust-jemalloc-sys];

  # NOTE: The only change in frizbee 0.7.0 was nixpkgs incompatible rust semantic changes
  # Patch just reverts https://github.com/saghen/blink.cmp/commit/cc824ec85b789a54d05241389993c6ab8c040810
  # Taken from Nixpkgs' blink.cmp derivation, available under the MIT license
  cargoPatches = [
    ./patches/0001-pin-frizbee.patch
  ];

  cargoHash = "sha256-Qdt8O7IGj2HySb1jxsv3m33ZxJg96Ckw26oTEEyQjfs=";

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
