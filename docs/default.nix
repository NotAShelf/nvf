{
  inputs,
  pkgs,
  lib,
}: let
  inherit ((lib.importJSON ../release.json)) release;

  nvimModuleDocs = pkgs.nixosOptionsDoc {
    variablelistId = "nvf-options";
    warningsAreErrors = true;

    inherit
      (
        (lib.evalModules {
          specialArgs = {inherit inputs;};
          modules =
            import ../modules/modules.nix {
              inherit lib pkgs;
            }
            ++ [
              (
                let
                  # From nixpkgs:
                  #
                  # Recursively replace each derivation in the given attribute set
                  # with the same derivation but with the `outPath` attribute set to
                  # the string `"\${pkgs.attribute.path}"`. This allows the
                  # documentation to refer to derivations through their values without
                  # establishing an actual dependency on the derivation output.
                  #
                  # This is not perfect, but it seems to cover a vast majority of use
                  # cases.
                  #
                  # Caveat: even if the package is reached by a different means, the
                  # path above will be shown and not e.g.
                  # `${config.services.foo.package}`.
                  scrubDerivations = namePrefix: pkgSet:
                    builtins.mapAttrs (
                      name: value: let
                        wholeName = "${namePrefix}.${name}";
                      in
                        if builtins.isAttrs value
                        then
                          scrubDerivations wholeName value
                          // lib.optionalAttrs (lib.isDerivation value) {
                            inherit (value) drvPath;
                            outPath = "\${${wholeName}}";
                          }
                        else value
                    )
                    pkgSet;
                in {
                  _module = {
                    check = false;
                    args.pkgs = lib.mkForce (scrubDerivations "pkgs" pkgs);
                  };
                }
              )
            ];
        })
      )
      options
      ;

    transformOptions = opt:
      opt
      // {
        declarations =
          map (
            decl:
              if lib.hasPrefix (toString ../.) (toString decl)
              then
                lib.pipe decl [
                  toString
                  (lib.removePrefix (toString ../.))
                  (lib.removePrefix "/")
                  (x: {
                    url = "https://github.com/NotAShelf/nvf/blob/main/${x}";
                    name = "<nvf/${x}>";
                  })
                ]
              else if decl == "lib/modules.nix"
              then {
                url = "https://github.com/NixOS/nixpkgs/blob/master/${decl}";
                name = "<nixpkgs/lib/modules.nix>";
              }
              else decl
          )
          opt.declarations;
      };
  };

  # Generate the HTML manual pages
  html = pkgs.callPackage ./manual.nix {
    inherit inputs release;
    inherit (nvimModuleDocs) optionsJSON;
  };
in {
  # TODO: Use `hmOptionsDocs.optionsJSON` directly once upstream
  # `nixosOptionsDoc` is more customizable.
  options.json =
    pkgs.runCommand "options.json" {
      meta.description = "List of nvf options in JSON format";
    } ''
      mkdir -p $out/{share/doc,nix-support}
      cp -a ${nvimModuleDocs.optionsJSON}/share/doc/nixos $out/share/doc/nvf
      substitute \
        ${nvimModuleDocs.optionsJSON}/nix-support/hydra-build-products \
        $out/nix-support/hydra-build-products \
        --replace \
        '${nvimModuleDocs.optionsJSON}/share/doc/nixos' \
        "$out/share/doc/nvf"
    '';

  # Generate the `man home-configuration.nix` package
  manPages =
    pkgs.runCommand "nvf-reference-manpage" {
      nativeBuildInputs = [
        pkgs.buildPackages.installShellFiles
        pkgs.nixos-render-docs
      ];
      allowedReferences = ["out"];
    } ''
      # Generate manpages.
      mkdir -p $out/share/man/{man5,man1}

      nixos-render-docs -j $NIX_BUILD_CORES options manpage \
        --revision ${release} \
        --header ${./man/header.5} \
        --footer ${./man/footer.5} \
        ${nvimModuleDocs.optionsJSON}/share/doc/nixos/options.json \
        $out/share/man/man5/nvf.5

      cp ${./man/nvf.1} $out/share/man/man1/nvf.1
    '';

  manual = {
    inherit html;
    htmlOpenTool = pkgs.callPackage ./html-open-tool.nix {inherit html;};
  };
}
