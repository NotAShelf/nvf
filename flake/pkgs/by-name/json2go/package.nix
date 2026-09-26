{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "json2go";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "olexsmir";
    repo = "json2go";
    tag = "v${finalAttrs.version}";
    hash = "sha256-m//1MWEatyyJSt+MZ/1LzCA5Ia6snphb5KDeQmFyo1U=";
  };

  vendorHash = "sha256-0t5ul0FHBJw+xt9rBTcZeKa1wdHCNvbrUYZB8pACGvY=";

  meta = {
    description = "convert json to go type annotations";
    mainProgram = "json2go";
    homepage = "https://github.com/olexsmir/json2go";
    license = lib.licenses.unlicense;
    changelog = "${finalAttrs.meta.homepage}/releases/tag/${finalAttrs.version}";
  };
})
