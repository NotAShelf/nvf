{
  lib,
  tree-sitter,
  fetchFromGitHub,
  # Upstream ships the block and inline grammars in a single repository.
  language ? "asciidoc",
}:
tree-sitter.buildGrammar rec {
  inherit language;
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "cathaysia";
    repo = "tree-sitter-asciidoc";
    tag = "v${version}";
    hash = "sha256-sJlpYTmK3fAlY3K0OBOAxy6Tr6lDJhfr5+taAEHPG50=";
  };

  location = "tree-sitter-${language}";
  generate = true;

  meta = {
    description = "asciidoc grammar for tree-sitter";
    homepage = "https://github.com/cathaysia/tree-sitter-asciidoc";
    changelog = "https://github.com/cathaysia/tree-sitter-asciidoc/releases/tag/v${version}";
    license = lib.licenses.asl20;
  };
}
