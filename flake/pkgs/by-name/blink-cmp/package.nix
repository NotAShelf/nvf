{
  rustPlatform,
  fetchFromGitHub,
  writeShellScriptBin,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "blink-cmp";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "Saghen";
    repo = "blink.cmp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8lyDDrsh3sY7l0i0TPyhL69Oq0l63+/QPnLaU/mhq5A=";
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

  cargoHash = "sha256-IDoDugtNWQovfSstbVMkKHLBXKa06lxRWmywu4zyS3M=";
  useFetchCargoVendor = true;

  nativeBuildInputs = [
    (writeShellScriptBin "git" "exit 1")
  ];

  env.RUSTC_BOOTSTRAP = true;
})
