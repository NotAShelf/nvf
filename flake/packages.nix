{inputs, ...}: {
  perSystem = {
    config,
    pkgs,
    lib,
    ...
  }: let
    docs = import ../docs {inherit pkgs inputs lib;};
  in {
    packages = {
      inherit (docs.manual) htmlOpenTool;
      # Documentation
      docs = docs.manual.html;
      docs-html = docs.manual.html;
      docs-manpages = docs.manPages;
      docs-json = docs.options.json;
      docs-linkcheck = let
        site = config.packages.docs;
      in
        pkgs.testers.lycheeLinkCheck {
          inherit site;
          remap = {
            "https://notashelf.github.io/nvf/" = site;
          };
          extraConfig = {
            exclude = [];
            include_mail = true;
            include_verbatim = true;
          };
        };

      # Build and open the built manual in your system browser
      docs-html-wrapped = pkgs.writeScriptBin "docs-html-wrapped" ''
        #!${pkgs.stdenv.shell}
        # use xdg-open to open the docs in the browser
        ${pkgs.xdg-utils}/bin/xdg-open ${docs.manual.html}
      '';

      # Exposed neovim configurations
      nix = config.legacyPackages.neovim-nix;
      maximal = config.legacyPackages.neovim-maximal;
      default = config.legacyPackages.neovim-nix;

      # Published docker images
      docker-nix = let
        inherit (pkgs) bash gitFull buildEnv;
        inherit (config.legacyPackages) neovim-nix;
      in
        pkgs.dockerTools.buildImage {
          name = "nvf";
          tag = "latest";

          copyToRoot = buildEnv {
            name = "neovim-root";
            pathsToLink = ["/bin"];
            paths = [
              neovim-nix
              gitFull
              bash
            ];
          };

          config = {
            Cmd = ["${neovim-nix}/bin/nvim"];
            WorkingDir = "/home/neovim/demo";
            Volumes = {"/home/neovim/demo" = {};};
          };
        };
    };
  };
}
