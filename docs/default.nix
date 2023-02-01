{
  pkgs,
  lib ? import ../modules/lib/stdlib-extended.nix pkgs.lib,
  nmdSrc,
}: let
  nmd = import nmdSrc {inherit lib pkgs;};
  scrubbedPkgsModule = {
    imports = [
      {
        _module.args = {
          pkgs = lib.mkForce (nmd.scrubDerivations "pkgs" pkgs);
        };
      }
    ];
  };

  nvimModuleDocs = nmd.buildModulesDocs {
    modules =
      import ../modules/modules.nix {
        inherit pkgs lib;
        check = false;
      }
      ++ [scrubbedPkgsModule];
    moduleRootPaths = [./..];
    mkModuleUrl = path: "https://github.com/jordanisaacs/neovim-flake/blob/main/${path}#blob-path";
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
