{
  stdenv,
  lib,
  documentation-highlighter,
  revision,
  outputPath ? "share/doc/neovim-flake",
  options,
  nixos-render-docs,
}:
stdenv.mkDerivation {
  name = "neovim-flake-manual";
  src = builtins.path {
    path = ./manual;
    name = "neovim-flake-manual";
  };

  nativeBuildInputs = [nixos-render-docs];

  buildPhase = ''
    mkdir -p out/{highlightjs,media}

    cp -vt out/highlightjs \
      ${documentation-highlighter}/highlight.pack.js \
      ${documentation-highlighter}/LICENSE \
      ${documentation-highlighter}/mono-blue.css \
      ${documentation-highlighter}/loader.js

    cp ${./static/style.css} out/style.css

    substituteInPlace ./options.md \
      --replace-fail \
        '@OPTIONS_JSON@' \
        ${options.neovim-flake}/share/doc/nixos/options.json

    substituteInPlace ./manual.md \
      --replace-fail \
        '@NVF_VERSION@' \
        ${revision}


    # copy release notes
    cp -vr ${./release-notes} release-notes

    # generate manual from
    nixos-render-docs manual html \
      --manpage-urls ./manpage-urls.json \
      --revision ${lib.trivial.revisionWithDefault revision} \
      --script highlightjs/highlight.pack.js \
      --script highlightjs/loader.js \
      --stylesheet style.css \
      --stylesheet highlightjs/tomorrow-night.min.css \
      --stylesheet highlightjs/highlight-style.css \
      --toc-depth 2 \
      --section-toc-depth 2 \
      manual.md \
      out/index.xhtml
  '';

  installPhase = ''
    dest="$out/${outputPath}"
    mkdir -p "$(dirname "$dest")"
    mv out "$dest"

    mkdir -p $out/nix-support/
    echo "doc manual $dest index.html" >> $out/nix-support/hydra-build-products
  '';
}
