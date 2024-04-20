{
  inputs,
  pkgs,
  lib ? import ../lib/stdlib-extended.nix pkgs.lib inputs,
  manpageUrls ? pkgs.path + "/doc/manpage-urls.json",
  ...
}: let
  inherit (lib.modules) mkForce evalModules;
  inherit (lib.strings) hasPrefix removePrefix;
  inherit (lib.attrsets) isAttrs mapAttrs optionalAttrs recursiveUpdate isDerivation;
  inherit (builtins) fromJSON readFile;

  # release data
  release-config = fromJSON (readFile ../release.json);
  revision = release-config.release;

  # From home-manager:
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
  scrubDerivations = prefixPath: attrs: let
    scrubDerivation = name: value: let
      pkgAttrName = prefixPath + "." + name;
    in
      if isAttrs value
      then
        scrubDerivations pkgAttrName value
        // optionalAttrs (isDerivation value) {
          outPath = "\${${pkgAttrName}}";
        }
      else value;
  in
    mapAttrs scrubDerivation attrs;

  # Make sure the used package is scrubbed to avoid actually
  # instantiating derivations.
  scrubbedPkgsModule = {
    imports = [
      {
        _module.args = {
          pkgs = mkForce (scrubDerivations "pkgs" pkgs);
          pkgs_i686 = mkForce {};
        };
      }
    ];
  };

  # Specify the path to the module entrypoint
  nvimPath = toString ./..;
  buildOptionsDocs = args @ {
    modules,
    includeModuleSystemOptions ? true,
    warningsAreErrors ? true,
    ...
  }: let
    inherit ((evalModules {inherit modules;})) options;

    # Declaration of the Github site URL.
    # Takes a user, repo, and subpath, and returns a declaration site
    # as a string.
    githubDeclaration = user: repo: subpath: let
      urlRef = "github.com";
      branch = "main";
    in {
      url = "https://${urlRef}/${user}/${repo}/blob/${branch}/${subpath}";
      name = "<${repo}/${subpath}>";
    };
  in
    pkgs.buildPackages.nixosOptionsDoc ({
        inherit warningsAreErrors;

        options =
          if includeModuleSystemOptions
          then options
          else builtins.removeAttrs options ["_module"];

        transformOptions = opt:
          recursiveUpdate opt {
            # Clean up declaration sites to not refer to the neovim-flakee
            # source tree.
            declarations = map (decl:
              if hasPrefix nvimPath (toString decl)
              then
                githubDeclaration "notashelf" "neovim-flake"
                (removePrefix "/" (removePrefix nvimPath (toString decl)))
              else if decl == "lib/modules.nix"
              then
                # TODO: handle this in a better way (may require upstream
                # changes to nixpkgs)
                githubDeclaration "NixOS" "nixpkgs" decl
              else decl)
            opt.declarations;
          };
      }
      // builtins.removeAttrs args ["modules" "includeModuleSystemOptions"]);

  nvimModuleDocs = buildOptionsDocs {
    variablelistId = "neovim-flake-options";

    modules =
      import ../modules/modules.nix {
        inherit lib pkgs;
        check = false;
      }
      ++ [scrubbedPkgsModule];
  };

  # Generate the `man home-configuration.nix` package
  nvf-configuration-manual =
    pkgs.runCommand "neovim-flake-reference-manpage" {
      nativeBuildInputs = [pkgs.buildPackages.installShellFiles pkgs.nixos-render-docs];
      allowedReferences = ["out"];
    } ''
      # Generate manpages.
      mkdir -p $out/share/man/man5
      mkdir -p $out/share/man/man1

      nixos-render-docs -j $NIX_BUILD_CORES options manpage \
        --revision ${revision} \
        --header ${./man/header.5} \
        --footer ${./man/footer.5} \
        ${nvimModuleDocs.optionsJSON}/share/doc/nixos/options.json \
        $out/share/man/man5/neovim-flake.5

      cp ${./man/neovim-flake.1} $out/share/man/man1/neovim-flake.1
    '';

  # Generate the HTML manual pages
  neovim-flake-manual = pkgs.callPackage ./manual.nix {
    inherit revision manpageUrls;
    outputPath = "share/doc/neovim-flake";
    options = {
      neovim-flake = nvimModuleDocs.optionsJSON;
    };
  };

  html = neovim-flake-manual;
  htmlOpenTool = pkgs.callPackage ./html-open-tool.nix {} {inherit html;};
in {
  inherit (inputs) nmd;

  options = {
    # TODO: Use `hmOptionsDocs.optionsJSON` directly once upstream
    # `nixosOptionsDoc` is more customizable.
    json =
      pkgs.runCommand "options.json" {
        meta.description = "List of neovim-flake options in JSON format";
      } ''
        mkdir -p $out/{share/doc,nix-support}
        cp -a ${nvimModuleDocs.optionsJSON}/share/doc/nixos $out/share/doc/neovim-flake
        substitute \
          ${nvimModuleDocs.optionsJSON}/nix-support/hydra-build-products \
          $out/nix-support/hydra-build-products \
          --replace \
            '${nvimModuleDocs.optionsJSON}/share/doc/nixos' \
            "$out/share/doc/neovim-flake"
      '';
  };

  manPages = nvf-configuration-manual;
  manual = {inherit html htmlOpenTool;};
}
