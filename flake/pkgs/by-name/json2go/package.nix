{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "json2go";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "olexsmir";
    repo = "json2go";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2QGvPLQ7CADRNURTdnHgTCK2vyRHgtdR6YFPuTL9Ymo=";
  };

  vendorHash = null;

  meta = {
    description = "convert json to go type annotations";
    mainProgram = "json2go";
    homepage = "https://github.com/olexsmir/json2go";
    license = lib.licenses.unlicense;
    changelog = "${finalAttrs.meta.homepage}/releases/tag/${finalAttrs.version}";
  };
})
