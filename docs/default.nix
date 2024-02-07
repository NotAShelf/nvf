{
  pkgs,
  lib ? import ../lib/stdlib-extended.nix pkgs.lib,
  nmdSrc,
  ...
}: let
  nmd = import nmdSrc {
    inherit lib;
    # The DocBook output of `nixos-render-docs` doesn't have the change
    # `nmd` uses to work around the broken stylesheets in
    # `docbook-xsl-ns`, so we restore the patched version here.
    pkgs =
      pkgs
      // {
        docbook-xsl-ns =
          pkgs.docbook-xsl-ns.override {withManOptDedupPatch = true;};
      };
  };

  # Make sure the used package is scrubbed to avoid actually
  # instantiating derivations.
  scrubbedPkgsModule = {
    imports = [
      {
        _module.args = {
          pkgs = lib.mkForce (nmd.scrubDerivations "pkgs" pkgs);
          pkgs_i686 = lib.mkForce {};
        };
      }
    ];
  };

  dontCheckDefinitions = {_module.check = false;};

  githubDeclaration = user: repo: subpath: let
    urlRef = "main";
  in {
    url = "https://github.com/${user}/${repo}/blob/${urlRef}/${subpath}";
    name = "<${repo}/${subpath}>";
  };

  nvimPath = toString ./..;

  buildOptionsDocs = args @ {
    modules,
    includeModuleSystemOptions ? true,
    ...
  }: let
    inherit ((lib.evalModules {inherit modules;})) options;
  in
    pkgs.buildPackages.nixosOptionsDoc ({
        options =
          if includeModuleSystemOptions
          then options
          else builtins.removeAttrs options ["_module"];
        transformOptions = opt:
          opt
          // {
            # Clean up declaration sites to not refer to the Home Manager
            # source tree.
            declarations = map (decl:
              if lib.hasPrefix nvimPath (toString decl)
              then
                githubDeclaration "notashelf" "neovim-flake"
                (lib.removePrefix "/" (lib.removePrefix nvimPath (toString decl)))
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
    modules =
      import ../modules/modules.nix {
        inherit lib pkgs;
        check = false;
      }
      ++ [scrubbedPkgsModule];
    variablelistId = "neovim-flake-options";
  };

  release-config = builtins.fromJSON (builtins.readFile ../release.json);
  revision = "release-${release-config.release}";
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
        ${nvimModuleDocs.optionsJSON}/share/doc/nixos/options.json \
        $out/share/man/man5/neovim-flake.5
      cp ${./neovim-flake.1} $out/share/man/man1/neovim-flake.1
    '';
  # Generate the HTML manual pages
  neovim-flake-manual = pkgs.callPackage ./manual.nix {
    inherit revision;
    outputPath = "share/doc/neovim-flake";
    nmd = nmdSrc;
    options = {
      neovim-flake = nvimModuleDocs.optionsJSON;
    };
  };
  html = neovim-flake-manual;
  htmlOpenTool = pkgs.callPackage ./html-open-tool.nix {} {inherit html;};
in {
  inherit nmdSrc;

  options = {
    # TODO: Use `hmOptionsDocs.optionsJSON` directly once upstream
    # `nixosOptionsDoc` is more customizable.
    json =
      pkgs.runCommand "options.json" {
        meta.description = "List of Home Manager options in JSON format";
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
