{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  rust-jemalloc-sys,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "blink-cmp";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "Saghen";
    repo = "blink.cmp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-y8f+bmPkb3M6DzcUkJMxd2woDLoBYslne7aB8A0ejCk=";
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

  cargoHash = "sha256-3o2n4xwNF9Fc3VlPKf3lnvmN7FVus5jQB8gcXXwz50c=";

  env = {
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
