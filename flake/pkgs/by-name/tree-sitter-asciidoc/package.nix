{
  lib,
  tree-sitter,
  fetchFromGitHub,
}:
tree-sitter.buildGrammar rec {
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "cathaysia";
    repo = "tree-sitter-asciidoc";
    rev = "v${version}";
    hash = "sha256-sJlpYTmK3fAlY3K0OBOAxy6Tr6lDJhfr5+taAEHPG50=";
  };

  homepage = "https://github.com/cathaysia/tree-sitter-asciidoc";

  language = "asciidoc";
  location = "tree-sitter-asciidoc";

  generate = true;

  meta = {
    inherit homepage;
    description = "asciidoc grammar for tree-sitter";
    license = lib.licenses.asl20;
    changelog = "${homepage}/releases/tag/v${version}";
  };
}
