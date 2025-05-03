{
  stdenv,
  rustPlatform,
  vimUtils,
  gitMinimal,
  src,
  version,
}: let
  blink-fuzzy-lib = rustPlatform.buildRustPackage {
    pname = "blink-fuzzy-lib";
    inherit version src;

    # TODO: remove this if plugin stops using nightly rust
    env.RUSTC_BOOTSTRAP = true;

    useFetchCargoVendor = true;
    cargoHash = "sha256-IDoDugtNWQovfSstbVMkKHLBXKa06lxRWmywu4zyS3M=";

    nativeBuildInputs = [gitMinimal];
  };
in
  vimUtils.buildVimPlugin {
    pname = "blink-cmp";
    inherit version src;

    # blink references a repro.lua which is placed outside the lua/ directory
    doCheck = false;
    preInstall = let
      ext = stdenv.hostPlatform.extensions.sharedLibrary;
    in ''
      mkdir -p target/release
      ln -s ${blink-fuzzy-lib}/lib/libblink_cmp_fuzzy${ext} target/release/libblink_cmp_fuzzy${ext}
    '';

    # Module for reproducing issues
    nvimSkipModules = ["repro"];
  }
