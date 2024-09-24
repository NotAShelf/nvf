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

      # Build and open the built manual in your system browser
      docs-html-wrapped = pkgs.writeScriptBin "docs-html-wrapped" ''
        #!${pkgs.stdenv.shell}
        # use xdg-open to open the docs in the browser
        ${pkgs.xdg_utils}/bin/xdg-open ${docs.manual.html}
      '';

      # Exposed neovim configurations
      nix = config.legacyPackages.neovim-nix;
      maximal = config.legacyPackages.neovim-maximal;
      default = config.legacyPackages.neovim-nix;

      # Published docker images
      docker-nix = let
        inherit (pkgs) bash gitFull buildEnv dockerTools;
        inherit (config.legacyPackages) neovim-nix;
      in
        dockerTools.buildImage {
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
