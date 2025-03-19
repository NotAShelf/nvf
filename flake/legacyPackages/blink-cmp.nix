{
  rustPlatform,
  hostPlatform,
  vimUtils,
  git,
  src,
  version,
  fetchpatch,
}: let
  blink-fuzzy-lib = rustPlatform.buildRustPackage {
    pname = "blink-fuzzy-lib";
    inherit version src;

    # TODO: remove this if plugin stops using nightly rust
    env.RUSTC_BOOTSTRAP = true;

    useFetchCargoVendor = true;
    cargoHash = "sha256-F1wh/TjYoiIbDY3J/prVF367MKk3vwM7LqOpRobOs7I=";

    nativeBuildInputs = [git];
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
      echo -n "nix" > target/release/version
    '';

    # Borrowed from nixpkgs
    # TODO: Remove this patch when updating to next version
    patches = [
      (fetchpatch {
        name = "blink-add-bypass-for-nix.patch";
        url = "https://github.com/Saghen/blink.cmp/commit/6c83ef1ae34abd7ef9a32bfcd9595ac77b61037c.diff?full_index=1";
        hash = "sha256-304F1gDDKVI1nXRvvQ0T1xBN+kHr3jdmwMMp8CNl+GU=";
      })
    ];

    # Module for reproducing issues
    nvimSkipModule = ["repro"];
  }
