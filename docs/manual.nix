{
  inputs,
  path,
  stdenvNoCC,
  runCommandLocal,
  optionsJSON,
  release,
} @ args: let
  manual-release = args.release or "unstable";
in
  runCommandLocal "nvf-docs-html" {
    nativeBuildInputs = [
      (inputs.ndg.packages.${stdenvNoCC.system}.ndg.overrideAttrs
        {
          # FIXME: the tests take too long to build
          doCheck = false;
        })
    ];
  } ''
    mkdir -p $out/share/doc

    # Copy the markdown sources to be processed by ndg. This is not
    # strictly necessary, but allows us to modify the Markdown sources
    # as we see fit.
    cp -rvf ${./manual} ./manual

    # Replace variables following the @VARIABLE@ style in the manual
    # pages. This can be built into ndg at a later date.
    substituteInPlace ./manual/index.md \
      --subst-var-by NVF_VERSION ${manual-release}

    # Generate the final manual from a set of parameters. This uses
    # feel-co/ndg to render the web manual.
    ndg html \
      --jobs $NIX_BUILD_CORES --title "NVF" \
      --module-options ${optionsJSON}/share/doc/nixos/options.json \
      --manpage-urls ${path}/doc/manpage-urls.json \
      --options-depth 3 \
      --generate-search \
      --highlight-code \
      --input-dir ./manual \
      --output-dir "$out/share/doc"

    # Hydra support. Probably not necessary.
    mkdir -p $out/nix-support/
    echo "doc manual $dest index.html" >> $out/nix-support/hydra-build-products
  ''
