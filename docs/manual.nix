{
  lib,
  stdenvNoCC,
  # build inputs
  nixos-render-docs,
  documentation-highlighter,
  path,
  # nrd configuration
  release,
  optionsJSON,
}:
stdenvNoCC.mkDerivation {
  name = "nvf-manual";
  src = builtins.path {
    path = lib.sourceFilesBySuffices ./manual [".md"];
    name = "nvf-manual";
  };

  nativeBuildInputs = [nixos-render-docs];

  buildPhase = ''
    dest="$out/share/doc/nvf"
    mkdir -p "$(dirname "$dest")"
    mkdir -p $dest/{highlightjs,media}

    cp -vt $dest/highlightjs \
      ${documentation-highlighter}/highlight.pack.js \
      ${documentation-highlighter}/LICENSE \
      ${documentation-highlighter}/mono-blue.css \
      ${documentation-highlighter}/loader.js

    substituteInPlace ./options.md \
      --subst-var-by \
        OPTIONS_JSON \
        ${optionsJSON}/share/doc/nixos/options.json

    substituteInPlace ./manual.md \
      --subst-var-by \
        NVF_VERSION \
        ${release}

    # copy stylesheet
    cp ${./static/style.css} "$dest/style.css"

    # copy release notes
    cp -vr ${./release-notes} release-notes

    # generate manual from
    nixos-render-docs manual html \
      --manpage-urls ${path + "/doc/manpage-urls.json"} \
      --revision ${lib.trivial.revisionWithDefault release} \
      --stylesheet style.css \
      --script highlightjs/highlight.pack.js \
      --script highlightjs/loader.js \
      --toc-depth 2 \
      --section-toc-depth 1 \
      manual.md \
      "$dest/index.xhtml"

      mkdir -p $out/nix-support/
      echo "doc manual $dest index.html" >> $out/nix-support/hydra-build-products
  '';
}
