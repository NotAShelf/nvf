{
  rustPlatform,
  hostPlatform,
  vimUtils,
  src,
  version,
}: let
  blink-fuzzy-lib = rustPlatform.buildRustPackage {
    pname = "blink-fuzzy-lib";
    inherit version src;

    env = {
      # TODO: remove this if plugin stops using nightly rust
      RUSTC_BOOTSTRAP = true;
    };
    cargoLock = {
      lockFile = "${src}/Cargo.lock";
      outputHashes = {
        "frizbee-0.1.0" = "sha256-pt6sMsRyjXrbrTK7t/YvWeen/n3nU8UUaiNYTY1LczE=";
      };
    };
  };
  libExt =
    if hostPlatform.isDarwin
    then "dylib"
    else "so";
in
  vimUtils.buildVimPlugin {
    pname = "blink-cmp";
    inherit version src;
    preInstall = ''
      mkdir -p target/release
      ln -s ${blink-fuzzy-lib}/lib/libblink_cmp_fuzzy.${libExt} target/release/libblink_cmp_fuzzy.${libExt}
    '';
  }
