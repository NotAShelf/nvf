{
  pkgs,
  lib ? import ../lib/stdlib-extended.nix pkgs.lib,
  nmdSrc,
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

  githubDeclaration = user: repo: subpath: let
    urlRef = "main";
  in {
    url = "https://github.com/${user}/${repo}/blob/${urlRef}/${subpath}";
    name = "<${repo}/${subpath}>";
  };

  dontCheckDefinitions = {_module.check = false;};

  nvimPath = toString ./..;

  buildOptionsDocs = args @ {
    modules,
    includeModuleSystemsOptions ? true,
    ...
  }: let
    options = (lib.evalModules {inherit modules;}).options;
  in
    pkgs.buildPackages.nixosOptionsDoc
    ({
        options =
          if includeModuleSystemsOptions
          then options
          else builtins.removeAttrs (options ["_module"]);
        transformOptions = opt:
          opt
          // {
            # Clean up declaration sites to not refer to local source tree
            declarations =
              map
              (decl:
                if lib.hasPrefix nvimPath (toString decl)
                then
                  githubDeclaration "notashelf" "neovim-flake"
                  (lib.removePrefix "/" (lib.removePrefix nvimPath (toString decl)))
                else decl)
              opt.declarations;
          };
      }
      // builtins.removeAttrs args ["modules" "includeModuleSystemsOptions"]);

  nvimModuleDocs = buildOptionsDocs {
    modules =
      import ../modules/modules.nix
      {
        inherit pkgs lib;
        check = false;
      }
      ++ [scrubbedPkgsModule];
    variablelistId = "neovim-flake-options";
  };

  docs = nmd.buildDocBookDocs {
    pathName = "neovim-flake";
    projectName = "neovim-flake";
    modulesDocs = [
      {
        docBook = pkgs.linkFarm "nvim-module-docs-for-nmd" {
          "nmd-result/neovim-flake-options.xml" = nvimModuleDocs.optionsDocBook;
        };
      }
    ];
    documentsDirectory = ./.;
    documentType = "book";
    chunkToc = ''
      <toc>
        <d:tocentry xmlns:d="http://docbook.org/ns/docbook" linkend="book-neovim-flake-manual">
          <?dbhtml filename="index.html"?>
          <d:tocentry linkend="ch-options">
            <?dbhtml filename="options.html"?>
          </d:tocentry>
          <d:tocentry linkend="ch-release-notes">
            <?dbhtml filename="release-notes.html"?>
          </d:tocentry>
        </d:tocentry>
      </toc>
    '';
  };
in {
  options.json =
    pkgs.runCommand "options.json"
    # TODO: Use `nvimOptionsDoc.optionsJSON` directly once upstream
    # `nixosOptionsDoc` is more customizable
    {
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

  inherit (docs) manPages;

  manual = {inherit (docs) html htmlOpenTool;};
}
