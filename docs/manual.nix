{
  path,
  stdenvNoCC,
  optionsJSON,
  jaq,
  ndg,
  gnused,
} @ args: let
  manual-release = args.release or "unstable";
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "nvf-docs-html";
    version = manual-release;
    src = ./manual;

    nativeBuildInputs = [
      ndg
      jaq
      gnused
    ];

    patchPhase = ''
      # Replace variables following the @VARIABLE@ style in the manual
      # pages. This can be built into ndg at a later date.
      substituteInPlace index.md \
        --subst-var-by NVF_VERSION ${finalAttrs.version}

      language_options=$(cat "${optionsJSON}/share/doc/nixos/options.json" | jaq -r 'keys
        | map(select(test("^vim\\.languages\\.[^.]+\\.enable$")))
        | map("- {option}`" + . + "`")
        | join("\n")'
      )

      substituteInPlace configuring/languages.md \
        --subst-var-by NVF_LANGUAGES_ENABLE "$language_options"
    '';

    buildPhase = ''
      mkdir -p queries/nix

      # apply nix injections
      sed -n -f /dev/stdin ${../modules/plugins/languages/nix.nix} <<'EOF' > ./queries/nix/injections.scm
      /type = "injections"/,/^[[:space:]]*};/ {
        /query = '''/,/^[[:space:]]*''';/ {
          /query = '''/d
          /^[[:space:]]*''';/d
          p
        }
      }
      EOF

      # Syntactica doesnt support `query` so we patch it with the closest it does,
      # which is `haskell` :bwaa:
      sed -i 's|#set! injection\.language "query"|#set! injection.language "haskell"|' ./queries/nix/injections.scm

      # Generate the final manual from a set of parameters. This uses
      # feel-co/ndg to render the web manual.
      ndg --config-file ${./ndg.toml} html \
        --jobs $NIX_BUILD_CORES --title "NVF" \
        --module-options ${optionsJSON}/share/doc/nixos/options.json \
        --manpage-urls ${path}/doc/manpage-urls.json \
        --input-dir . \
        --output-dir build
    '';

    installPhase = ''
      mkdir -p $out/share/doc
      cp -r build/* $out/share/doc/

      cp ./logo.png $out/share/doc/assets/logo.png

      # Hydra support. Probably not necessary.
      mkdir -p $out/nix-support/
      echo "doc manual $out/share/doc index.html" >> $out/nix-support/hydra-build-products
    '';
  })
