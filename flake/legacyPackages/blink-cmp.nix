{
  rustPlatform,
  hostPlatform,
  vimUtils,
  git,
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
    nativeBuildInputs = [git];
    cargoLock = {
      lockFile = "${src}/Cargo.lock";
      allowBuiltinFetchGit = true;
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

    # blink references a repro.lua which is placed outside the lua/ directory
    doCheck = false;
    preInstall = ''
      mkdir -p target/release
      ln -s ${blink-fuzzy-lib}/lib/libblink_cmp_fuzzy.${libExt} target/release/libblink_cmp_fuzzy.${libExt}
    '';
  }
