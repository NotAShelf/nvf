{
  pkgs,
  lib,
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

  dontCheckDefinitions = {_module.check = false;};

  nvimModuleDocs = nmd.buildModulesDocs {
    modules =
      import ../modules/modules.nix {
        inherit pkgs lib;
        check = false;
      }
      ++ [scrubbedPkgsModule dontCheckDefinitions];
    moduleRootPaths = [./..];
    mkModuleUrl = path: "https://github.com/notashelf/neovim-flake/blob/main/${path}#blob-path";
    channelName = "neovim-flake";
    docBook.id = "neovim-flake-options";
  };

  docs = nmd.buildDocBookDocs {
    pathName = "neovim-flake";
    projectName = "neovim-flake";
    modulesDocs = [nvimModuleDocs];
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
  options.json = nvimModuleDocs.json.override {path = "share/doc/neovim-flake/options.json";};
  manPages = docs.manPages;
  manual = {inherit (docs) html htmlOpenTool;};
}
